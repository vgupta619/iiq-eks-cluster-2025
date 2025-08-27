#---------------------------------------------------------------------------------------------------
# DynamoDB Table for State Locking
#---------------------------------------------------------------------------------------------------

locals {
  # The table must have a primary key named LockID.
  # See below for more detail.
  # https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table
  lock_key_id = "LockID"

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

resource "aws_dynamodb_table" "eks_dynamodb_table" {
  name         = "${var.environment}-${var.cluster_type}-${var.cluster_name}-${var.application}-${var.dynamodb_table_name}"
  billing_mode = var.dynamodb_table_billing_mode
  hash_key     = local.lock_key_id

  attribute {
    name = local.lock_key_id
    type = "S"
  }

  server_side_encryption {
    enabled     = var.dynamodb_enable_server_side_encryption
    kms_key_arn = var.eks_kms_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.merged_tags
}