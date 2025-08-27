variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "VPC id where cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used by control plane and nodes"
  type        = list(string)
}


variable "enable_bootstrap_node_group" {
  description = "Create a tiny managed node group to host Karpenter controller"
  type        = bool
  default     = true
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

variable "bootstrap_min_size" {
  type    = number
  default = 1
}

variable "bootstrap_max_size" {
  type    = number
  default = 1
}

variable "bootstrap_ssh_key_name" {
  description = "Optional SSH key name for bootstrap nodes (set null to skip remote_access)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "capacity_type" {
  description = "Instance capacity type used to create node group"
  type        = string
  default     = ""
}