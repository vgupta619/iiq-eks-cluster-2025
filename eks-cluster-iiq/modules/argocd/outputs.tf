output "argocd_namespace" {
  value       = kubernetes_namespace.argocd.metadata[0].name
  description = "Namespace where ArgoCD is deployed"
}

output "argocd_admin_password" {
  value       = var.admin_password
  description = "Initial ArgoCD admin password"
  sensitive   = true
}

output "argocd_application_name" {
  value       = kubernetes_manifest.argocd_app.manifest["metadata"]["name"]
  description = "Pre-configured ArgoCD application name"
}
