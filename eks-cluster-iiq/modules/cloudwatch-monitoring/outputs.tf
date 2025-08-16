output "cloudwatch_agent_helm_release" {
  value       = helm_release.cloudwatch_agent.name
  description = "CloudWatch agent Helm release name"
}

output "cloudwatch_namespace" {
  value       = kubernetes_namespace.cloudwatch.metadata[0].name
  description = "Namespace where CloudWatch agent is deployed"
}