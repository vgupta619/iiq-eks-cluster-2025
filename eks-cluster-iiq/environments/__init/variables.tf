#---------------------------------------------------------------------------------------------------
# General
#---------------------------------------------------------------------------------------------------

variable "environment" {
  description = "Name of the environment, e.g: prod, pre, test, dev"
  type        = string
}

variable "application" {
  description = "Name of the application for the deployment"
  default     = "soda"
  type        = string
}

variable "cluster_type" {
  description = "Name of the application for the deployment"
  default     = "eks"
  type        = string
}

variable "cluster_name" {
  description = "Name of the application for the deployment"
  default     = ""
  type        = string
}

variable "region" {
  description = "AWS Region to create EKS cluster"
  type        = string
  default     = ""
}

variable "aws_account" {
  description = "AWS account number for EKS cluster"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}