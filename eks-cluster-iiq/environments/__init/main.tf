# Create S3 bucket and dynamodb table for state and lockfile before backend file execute.

module "eks_s3_backend" {
  source       = "../../modules/s3/"
  cluster_type = var.cluster_type
  cluster_name = var.cluster_name
  environment  = var.environment
  application  = var.application
}

module "eks_dynamodb_table" {
  source          = "../../modules/dynamodb/"
  eks_kms_key_arn = module.eks_s3_backend.eks_kms_key_arn
  cluster_type    = var.cluster_type
  cluster_name    = var.cluster_name
  environment     = var.environment
  application     = var.application
}