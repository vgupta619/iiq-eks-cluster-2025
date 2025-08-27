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

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

#---------------------------------------------------------------------------------------------------
# VPC
#---------------------------------------------------------------------------------------------------

variable "cidr_range" {
  description = "CIDR block to use for the environment, e.g. `\"172.18.0.0/16\"`"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name Suffix of the VPC, if you don't want to use the default: environment-customer-application-vpc"
  type        = string
  default     = ""
}

variable "private_cidr_range" {
  description = "List of private subnets to create in the environment, e.g. `[\"172.18.0.0/21\", \"172.18.8.0/21\"]`"
  type        = list(string)
  default     = []
}

variable "public_cidr_range" {
  description = "List of public subnets to create in the environment, e.g. `[\"172.18.168.0/22\", \"172.18.172.0/22\"]`"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "List of public subnets to create in the environment, e.g. `[\"172.18.168.0/22\", \"172.18.172.0/22\"]`"
  type        = list(string)
  default     = []
}

#---------------------------------------------------------------------------------------------------
# EKS
#---------------------------------------------------------------------------------------------------

variable "eks_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "capacity_type" {
  description = "Instance capacity type used to create node group"
  type        = string
  default     = ""
}

variable "bootstrap_instance_types" {
  description = "Instance types for the bootstrap node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "bootstrap_desired_size" {
  description = "Desired size for bootstrap node group"
  type        = number
  default     = 1
}