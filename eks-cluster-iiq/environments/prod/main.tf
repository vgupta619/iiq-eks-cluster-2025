provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source          = "../../modules/vpc"
  name            = "prod"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
  tags = {
    Environment = "prod"
    Project     = "eks-project"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "prod-eks"
  eks_version        = "1.30"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  enable_bootstrap_node_group = true
  bootstrap_instance_types    = ["t3.small"]
  bootstrap_desired_size      = 1

  tags = {
    Environment = "prod"
    Project     = "myproject"
  }
}

# Aurora for non-prod (serverless v2)
module "aurora_nonprod" {
  source             = "../../modules/provisioned-aurora"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  eks_nodes_sg_id    = module.eks.nodes_security_group_id
}