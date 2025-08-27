variable "k8s_host" {
  type        = string
  description = "Kubernetes API server endpoint"
}

variable "k8s_cluster_ca_certificate" {
  type        = string
  description = "Base64 encoded CA for cluster"
}

variable "k8s_token" {
  type        = string
  description = "Token for accessing Kubernetes cluster"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type        = string
  default     = "5.52.0"
  description = "Helm chart version for ArgoCD"
}

variable "service_type" {
  type        = string
  default     = "LoadBalancer"
  description = "Service type for ArgoCD server"
}

variable "ingress_enabled" {
  type        = bool
  default     = false
  description = "Enable ingress for ArgoCD server"
}

variable "ingress_host" {
  type        = string
  default     = ""
  description = "Hostname for ArgoCD ingress if enabled"
}

variable "extra_repositories" {
  type        = string
  default     = ""
  description = "Extra git repositories for ArgoCD to monitor"
}

variable "rbac_default_policy" {
  type        = string
  default     = "role:admin"
  description = "Default RBAC policy for ArgoCD"
}

variable "admin_password" {
  type        = string
  description = "Initial ArgoCD admin password"
  sensitive   = true
}

variable "application_name" {
  type        = string
  default     = "my-app"
  description = "Name of the pre-configured ArgoCD application"
}

variable "application_project" {
  type        = string
  default     = "default"
  description = "ArgoCD project for the application"
}

variable "application_repo" {
  type        = string
  default     = ""
  description = "Git repository URL for the application"
}

variable "application_branch" {
  type        = string
  default     = "main"
  description = "Git branch to track for the application"
}

variable "application_path" {
  type        = string
  default     = "."
  description = "Path in the Git repo for the application manifests"
}

variable "application_target_namespace" {
  type        = string
  default     = "default"
  description = "Target namespace in EKS where the application will be deployed"
}