variable "k8s_host" {
  type        = string
  description = "Kubernetes API endpoint"
}

variable "k8s_cluster_ca_certificate" {
  type        = string
  description = "Base64-encoded Kubernetes cluster CA certificate"
}

variable "k8s_token" {
  type        = string
  description = "Kubernetes service account token"
}

variable "namespace" {
  type        = string
  default     = "amazon-cloudwatch"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "chart_version" {
  type        = string
  default     = "1.1.2"
}

variable "collection_interval" {
  type        = number
  default     = 60
  description = "Metrics collection interval in seconds"
}

variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable CloudWatch Container Insights"
}

variable "cloudwatch_agent_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN for IRSA (CloudWatch agent)"
}