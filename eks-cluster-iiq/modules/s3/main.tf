# s3 bucket for backend, use to store statefile in s3 for better relibility and security

locals {
  define_lifecycle_rule = var.noncurrent_version_expiration != null || length(var.noncurrent_version_transitions) > 0

  tags = {
    Cluster_type   = lower(var.cluster_type)
    Cluster_name   = lower(var.cluster_name)
    Application    = lower(var.application)
    TerraformBuild = "true"
  }

  merged_tags = merge(local.tags, var.additional_tags)

  merged_tags_length = length(keys(local.merged_tags))
}

data "aws_region" "state" {
}

#---------------------------------------------------------------------------------------------------
# KMS Key to Encrypt S3 Bucket
#---------------------------------------------------------------------------------------------------

resource "aws_kms_key" "eks_kms_key" {
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_key_rotation

  tags = local.merged_tags
}

resource "aws_kms_alias" "eks_kms_key" {
  name          = "alias/${var.cluster_type}-${var.cluster_name}-${var.application}-${var.kms_key_alias}"
  target_key_id = aws_kms_key.eks_kms_key.key_id
}

#---------------------------------------------------------------------------------------------------
# Bucket Policies
#---------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "state_force_ssl" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.eks_s3_bucket.arn,
      "${aws_s3_bucket.eks_s3_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

#---------------------------------------------------------------------------------------------------
# Bucket
#---------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "state_force_ssl" {
  bucket = aws_s3_bucket.eks_s3_bucket.id
  policy = data.aws_iam_policy_document.state_force_ssl.json

  depends_on = [aws_s3_bucket_public_access_block.state]
}

resource "aws_s3_bucket" "eks_s3_bucket" {
  bucket_prefix = var.override_s3_bucket_name ? null : var.state_bucket_prefix
  bucket        = var.override_s3_bucket_name ? "${var.cluster_type}-${var.cluster_name}-${var.application}-tfstate-bucket" : null
  force_destroy = var.s3_bucket_force_destroy

  tags = local.merged_tags
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.eks_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "eks_s3_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.state]
  bucket     = aws_s3_bucket.eks_s3_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "eks_s3_bucket_versioning" {
  bucket = aws_s3_bucket.eks_s3_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_logging" "eks_s3_bucket_logging" {
  count = var.s3_logging_target_bucket != null ? 1 : 0

  bucket        = aws_s3_bucket.eks_s3_bucket.id
  target_bucket = var.s3_logging_target_bucket
  target_prefix = var.s3_logging_target_prefix
}

resource "aws_s3_bucket_server_side_encryption_configuration" "eks_s3_sse" {
  bucket = aws_s3_bucket.eks_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.eks_kms_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "eks_s3_bucket_lifecycle_configuration" {
  count  = local.define_lifecycle_rule ? 1 : 0
  bucket = aws_s3_bucket.eks_s3_bucket.id

  rule {
    id     = "auto-archive"
    status = "Enabled"

    filter {
      
    }
    dynamic "noncurrent_version_transition" {
      for_each = var.noncurrent_version_transitions

      content {
        noncurrent_days = noncurrent_version_transition.value.days
        storage_class   = noncurrent_version_transition.value.storage_class
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.noncurrent_version_expiration != null ? [var.noncurrent_version_expiration] : []

      content {
        noncurrent_days = noncurrent_version_expiration.value.days
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.eks_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

