# Dynamodb table id and arn

output "eks_dynamodb_id" {
  value = aws_dynamodb_table.eks_dynamodb_table.id
}

output "eks_dynamodb_arn" {
  value = aws_dynamodb_table.eks_dynamodb_table.arn
}