# S3 bucket outputs

output "eks_s3_bucket_id" {
  value = aws_s3_bucket.eks_s3_bucket.id
}

output "eks_s3_bucket_arn" {
  value = aws_s3_bucket.eks_s3_bucket.arn
}

# KMS key outputs

output "eks_kms_key_id" {
  value = aws_kms_key.eks_kms_key.id
}

output "eks_kms_key_arn" {
  value = aws_kms_key.eks_kms_key.arn
}