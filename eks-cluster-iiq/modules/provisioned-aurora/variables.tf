variable "vpc_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "eks_nodes_sg_id" {}
variable "sns_topic_arn" {
  type        = string
  default     = null
  description = "Optional SNS topic ARN to notify on alarm"
}