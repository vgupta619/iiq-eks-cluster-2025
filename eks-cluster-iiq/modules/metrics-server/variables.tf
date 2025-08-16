variable "k8s_host" {
  type        = string
  description = "Kubernetes API server endpoint"
}

variable "k8s_cluster_ca_certificate" {
  type        = string
  description = "Kubernetes cluster CA certificate (base64 encoded)"
}

variable "k8s_token" {
  type        = string
  description = "Service account token for Kubernetes access"
}

variable "chart_version" {
  type        = string
  default     = "5.12.2" # latest compatible version
  description = "Metrics Server Helm chart version"
}