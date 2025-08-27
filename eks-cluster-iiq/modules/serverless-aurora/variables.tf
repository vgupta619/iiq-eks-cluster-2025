variable "vpc_id" {
  description = "VPC id where cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used by control plane and nodes"
  type        = list(string)
}

variable "eks_nodes_sg_id" {
  description = "Allow secure connection from node to aurora."
}

variable "sns_topic_arn" {
  type        = string
  default     = null
  description = "Optional SNS topic ARN for CloudWatch alarm notifications"
}

variable "aurora_cluster_identifier" {
  description = "Aurora cluster name"
  type        = string
}

variable "engine_version" {
  description = "aurora engine version"
}

variable "master_username" {
  description = "Aurora admin user name"
  type        = string
}

variable "master_password" {
  description = "Aurora admin password"
  type        = string
}