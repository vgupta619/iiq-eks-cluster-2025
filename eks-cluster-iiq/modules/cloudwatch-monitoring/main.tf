# CloudWatch module to use the official Helm chart, which is simpler, supports IRSA, and handles RBAC and DaemonSet automatically

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
    token                  = var.k8s_token
  }
}

resource "kubernetes_namespace" "cloudwatch" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cloudwatch_agent" {
  name             = "cloudwatch-agent"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "cloudwatch-agent"
  namespace        = kubernetes_namespace.cloudwatch.metadata[0].name
  create_namespace = false
  version          = var.chart_version

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "metricsCollectionInterval"
    value = var.collection_interval
  }

  set {
    name  = "logs.enableInsights"
    value = var.enable_container_insights
  }

  # Optional: attach IRSA IAM role
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cloudwatch_agent_role_arn
  }
}