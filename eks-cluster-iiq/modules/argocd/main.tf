/*
Automatically creates an initial admin password using a Kubernetes secret.
Deploys a pre-configured ArgoCD Application so you can immediately deploy your apps from a Git repository.
*/

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
    token                  = var.k8s_token
  }
}

# -----------------------
# Namespace
# -----------------------
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# -----------------------
# ArgoCD Helm Release
# -----------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  version          = var.chart_version

  set {
    name  = "server.service.type"
    value = var.service_type
  }

  set {
    name  = "server.ingress.enabled"
    value = var.ingress_enabled
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = var.ingress_host
  }

  set {
    name  = "configs.cm.extraRepositories"
    value = var.extra_repositories
  }

  set {
    name  = "rbac.policy.default"
    value = var.rbac_default_policy
  }
}

# -----------------------
# Admin Password Secret
# -----------------------
resource "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    password = base64encode(var.admin_password)
  }

  type = "Opaque"
}

# -----------------------
# Pre-configured ArgoCD Application
# -----------------------
resource "kubernetes_manifest" "argocd_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.application_name
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = var.application_project
      source = {
        repoURL        = var.application_repo
        targetRevision = var.application_branch
        path           = var.application_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.application_target_namespace
      }
      syncPolicy = {
        automated = {
          prune = true
          selfHeal = true
        }
      }
    }
  }
}
