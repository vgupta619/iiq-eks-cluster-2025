provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source          = "../../modules/vpc"
  name            = "dev"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
  tags = {
    Environment = "dev"
    Project     = "eks-project"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name           = "dev-eks"
  eks_version            = "1.30"
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnets

  enable_bootstrap_node_group = true
  bootstrap_instance_types    = ["t3.small"]
  bootstrap_desired_size      = 1

  tags = {
    Environment = "dev"
    Project     = "myproject"
  }
}

# Aurora for non-prod (serverless v2)
module "aurora_nonprod" {
  source             = "../../modules/serverless-aurora"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  eks_nodes_sg_id    = module.eks.nodes_security_group_id
}

module "karpenter" {
  source                     = "../../modules/karpenter-autoscaler"
  cluster_name               = module.eks.cluster_name
  cluster_endpoint           = module.eks.cluster_endpoint
  oidc_provider_arn          = module.eks.oidc_provider_arn
}

module "metrics_server" {
  source                     = "../../modules/metrics-server"
  k8s_host                   = data.aws_eks_cluster.cluster.endpoint
  k8s_cluster_ca_certificate = data.aws_eks_cluster.cluster.certificate_authority[0].data
  k8s_token                  = data.aws_eks_cluster_auth.cluster.token
}

module "cloudwatch_monitoring" {
  source                     = "../../modules/cloudwatch-monitoring"
  k8s_host                   = data.aws_eks_cluster.cluster.endpoint
  k8s_cluster_ca_certificate = data.aws_eks_cluster.cluster.certificate_authority[0].data
  k8s_token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_name               = aws_eks_cluster.this.name
  cloudwatch_agent_role_arn  = aws_iam_role.cloudwatch_agent.arn
}

module "argocd" {
  source                     = "../../modules/argocd"
  k8s_host                   = data.aws_eks_cluster.cluster.endpoint
  k8s_cluster_ca_certificate = data.aws_eks_cluster.cluster.certificate_authority[0].data
  k8s_token                  = data.aws_eks_cluster_auth.cluster.token
  admin_password             = "admin123"
  application_name           = "my-app"
  application_repo           = "https://github.com/my-org/my-app.git"
  application_branch         = "main"
  application_path           = "deploy/manifests"
  application_target_namespace = "default"
}