# Variables defaults for eks prod environements
cluster_type    = "eks"
cluster_name    = "cold-drinks"
environment     = "util"
application     = "soda"
region          = "ap-south-1"
aws_account     = ""
additional_tags = {}

###############################################################################
# VPC
###############################################################################

cidr_range         = "10.0.0.0/16"
vpc_name           = ""
private_cidr_range = ["10.0.101.0/24", "10.0.102.0/24"]
public_cidr_range  = ["10.0.1.0/24", "10.0.2.0/24"]
azs                = ["ap-south-1a", "ap-south-1b"]

###############################################################################
# EKS
###############################################################################

eks_version              = "1.30"
capacity_type            = "ON_DEMAND"
bootstrap_instance_types = ["t3.small"]
bootstrap_desired_size   = 1

###############################################################################
# ArgoCD
###############################################################################

admin_password               = "admin123"
application_name             = "iiq"
application_repo             = "https://github.com/vgupta619/iiq-eks-cluster.git"
application_branch           = "main"
application_path             = "gitops-iiq/bootstrap/apps"
application_target_namespace = "argocd"
