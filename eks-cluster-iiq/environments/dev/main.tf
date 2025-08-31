locals {
  # Naming conventions and default configurations

  resource_prefix  = "${lower(var.environment)}-${lower(var.cluster_type)}-${lower(var.application)}"
  vpc_name_default = "${lower(var.environment)}-${lower(var.cluster_type)}-${lower(var.cluster_name)}-${lower(var.application)}-vpc"
  vpc_name         = var.vpc_name != "" ? lower(var.vpc_name) : local.vpc_name_default

  # Tagging

  tags = {
    Cluster_type   = lower(var.cluster_type)
    Cluster_name   = lower(var.cluster_name)
    Environment    = lower(var.environment)
    Application    = lower(var.application)
    TerraformBuild = "true"
  }
  merged_tags = merge(local.tags, var.additional_tags)

  merged_tags_length = length(keys(local.merged_tags))

}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

module "vpc" {
  source          = "../../modules/vpc"
  name            = "${var.environment}-${var.cluster_type}-${var.cluster_name}-${var.application}"
  vpc_cidr        = var.cidr_range
  public_subnets  = var.public_cidr_range
  private_subnets = var.private_cidr_range
  azs             = var.azs
  tags            = local.merged_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "${var.environment}-${var.cluster_type}-${var.cluster_name}-${var.application}"
  eks_version        = var.eks_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  capacity_type      = var.capacity_type
  enable_bootstrap_node_group = true
  bootstrap_instance_types    = var.bootstrap_instance_types
  bootstrap_desired_size      = var.bootstrap_desired_size
  tags                        = local.tags

}

# Aurora for non-prod (serverless v2)
module "aurora_nonprod" {
  source                    = "../../modules/serverless-aurora"
  vpc_id                    = module.vpc.vpc_id
  aurora_cluster_identifier = "${var.environment}-${var.cluster_type}-${var.cluster_name}-${var.application}-aurora-serverless"
  aurora_sg                 = "${var.environment}-${var.cluster_type}-${var.cluster_name}-${var.application}-aurora-sg"
  aurora_db_sg              = "${var.environment}-${var.cluster_type}-${var.cluster_name}-${var.application}-aurora-db-subnetgroup"
  engine_version            = var.engine_version
  master_username           = var.master_username
  master_password           = var.master_password
  private_subnet_ids        = module.vpc.private_subnets
  eks_nodes_sg_id           = module.eks.nodes_security_group_id
}

module "karpenter" {
  source            = "../../modules/karpenter-autoscaler"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module "metrics_server" {
  source                     = "../../modules/metrics-server"
  k8s_host                   = module.eks.cluster_endpoint
  k8s_cluster_ca_certificate = module.eks.cluster_certificate_authority_data[0].data
  k8s_token                  = module.eks.cluster_token
}

# module "cloudwatch_monitoring" {
#   source                     = "../../modules/cloudwatch-monitoring"
#   k8s_host                   = module.eks.cluster_endpoint
#   k8s_cluster_ca_certificate = module.eks.cluster_certificate_authority_data[0].data
#   k8s_token                  = module.eks.cluster_token
#   cluster_name               = module.eks.cluster_name
#   cloudwatch_agent_role_arn  = #aws_iam_role.cloudwatch_agent.arn
# }

module "cloudwatch-agent" {
  source = "../../modules/cloudwatch-agent/"
}

