output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "nodes_security_group_id" {
  value = aws_security_group.nodes.id
}

output "bootstrap_node_role_arn" {
  value = var.enable_bootstrap_node_group ? aws_iam_role.bootstrap_node_role[0].arn : ""
}

output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi.arn
}
