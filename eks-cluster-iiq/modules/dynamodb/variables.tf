#---------------------------------------------------------------------------------------------------
# General
#---------------------------------------------------------------------------------------------------

variable "environment" {
  description = "Name of the environment, e.g: prod, pre, test, dev"
  type        = string
}

variable "application" {
  description = "Name of the application for the deployment"
  default     = ""
  type        = string
}

variable "cluster_type" {
  description = "Name of the application for the deployment"
  default     = ""
  type        = string
}

variable "cluster_name" {
  description = "Name of the application for the deployment"
  default     = ""
  type        = string
}

#---------------------------------------------------------------------------------------------------
# DynamoDB Table for State Locking
#---------------------------------------------------------------------------------------------------

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to use for state locking."
  type        = string
  default     = "remote-state-lock"
}

variable "dynamodb_table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_enable_server_side_encryption" {
  description = "Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK)"
  type        = bool
  default     = false
}

variable "eks_kms_key_arn" {
  description = "The key used to encrypt the remote state bucket"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}