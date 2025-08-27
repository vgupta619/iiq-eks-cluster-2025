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
# KMS Key for Encrypting S3 Buckets
#---------------------------------------------------------------------------------------------------

variable "kms_key_alias" {
  description = "The alias for the KMS key as viewed in AWS console. It will be automatically prefixed with `alias/`"
  type        = string
  default     = "remote-state-key"
}

variable "kms_key_description" {
  description = "The description of the key as viewed in AWS console."
  type        = string
  default     = "The key used to encrypt the remote state bucket."
}

variable "kms_key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  type        = number
  default     = 30
}

variable "kms_key_enable_key_rotation" {
  description = "Specifies whether key rotation is enabled."
  type        = bool
  default     = true
}

#---------------------------------------------------------------------------------------------------
# S3 Buckets
#---------------------------------------------------------------------------------------------------

variable "enable_replication" {
  description = "Set this to true to enable S3 bucket replication in another region"
  type        = bool
  default     = false
}

variable "state_bucket_prefix" {
  description = "Creates a unique state bucket name beginning with the specified prefix."
  type        = string
  default     = "eks-remote-state"
}

variable "noncurrent_version_transitions" {
  description = "Specifies when noncurrent object versions transitions. See the aws_s3_bucket document for detail."

  type = list(object({
    days          = number
    storage_class = string
  }))

  default = [
    {
      days          = 7
      storage_class = "GLACIER"
    }
  ]
}

variable "noncurrent_version_expiration" {
  description = "Specifies when noncurrent object versions expire. See the aws_s3_bucket document for detail."

  type = object({
    days = number
  })

  default = null
}

variable "s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from S3 buckets so that the buckets can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "s3_logging_target_bucket" {
  description = "The name of the bucket for log storage. The \"S3 log delivery group\" should have Objects-write und ACL-read permissions on the bucket."
  type        = string
  default     = null
}

variable "s3_logging_target_prefix" {
  description = "The prefix to apply on bucket logs, e.g \"logs/\"."
  type        = string
  default     = ""
}

#---------------------------------------------------------------------------------------------------
# Optionally specifying a fixed bucket name
#---------------------------------------------------------------------------------------------------

variable "override_s3_bucket_name" {
  description = "override s3 bucket name to disable bucket_prefix and create bucket with static name"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "If override_s3_bucket_name is true, use this bucket name instead of dynamic name with bucket_prefix"
  type        = string
  default     = ""
  validation {
    condition     = length(var.s3_bucket_name) == 0 || length(regexall("^[a-z0-9][a-z0-9\\-.]{1,61}[a-z0-9]$", var.s3_bucket_name)) > 0
    error_message = "Input variable s3_bucket_name is invalid. Please refer to https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}
variable "s3_bucket_name_replica" {
  description = "If override_s3_bucket_name is true, use this bucket name for replica instead of dynamic name with bucket_prefix"
  type        = string
  default     = ""
  validation {
    condition     = length(var.s3_bucket_name_replica) == 0 || length(regexall("^[a-z0-9][a-z0-9\\-.]{1,61}[a-z0-9]$", var.s3_bucket_name_replica)) > 0
    error_message = "Input variable s3_bucket_name_replica is invalid. Please refer to https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}


