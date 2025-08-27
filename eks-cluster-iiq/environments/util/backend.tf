# Backend configuration to store tfstate file in s3 bucket and lock file in Dynamodb

terraform {
  backend "s3" {
    bucket  = "eks-cold-drinks-soda-tfstate-bucket"
    key     = "util-eks-cold-drinks-soda-tfstate-bucket.tfstate"
    region  = "ap-south-1"
    encrypt = true
    #kms_key_id = "9658c776-b966-43d4-b84e-ec99ec50f151"
    dynamodb_table = "util-eks-cold-drinks-soda-remote-state-lock"
  }
}