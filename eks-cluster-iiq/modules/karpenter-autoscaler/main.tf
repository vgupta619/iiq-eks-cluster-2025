/*
Karpenter controller IAM role (IRSA)
IAM role + instance profile for EC2 nodes launched by Karpenter
Helm deployment of Karpenter
AWSNodeTemplate
Provisioner
Pod pending → Karpenter controller detects → IAM role used to create EC2 → Node joins cluster → Pod scheduled → Node terminated if unused
*/

locals {
  namespace = "karpenter"
  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

# ------------------------------------------------------
# IAM Role for Karpenter Controller (IRSA) - Karpenter controller (running in the cluster) uses this role to create and terminate nodes.
# ------------------------------------------------------
data "aws_iam_policy_document" "karpenter_controller_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "arn:aws:iam::", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:karpenter"]
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.cluster_name}-karpenter-controller"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_trust.json
  tags               = local.tags
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  name        = "${var.cluster_name}-karpenter-controller-policy"
  description = "Permissions for Karpenter Controller"
  policy      = file("${path.module}/policies/karpenter-controller.json")
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

# ------------------------------------------------------
# IAM Role + Instance Profile for nodes launched by Karpenter - Role attached to each node launched by Karpenter.
# ------------------------------------------------------
resource "aws_iam_role" "karpenter_node_role" {
  name = "${var.cluster_name}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "karpenter_node_profile" {
  name = "${var.cluster_name}-karpenter-node-profile"
  role = aws_iam_role.karpenter_node_role.name
  tags = local.tags
}

# ------------------------------------------------------
# Helm Chart Installation for Karpenter
# ------------------------------------------------------
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter/karpenter"
  chart            = "karpenter"
  version          = "0.37.0"
  namespace        = local.namespace
  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter_node_profile.name
  }
}

# ------------------------------------------------------
# Default AWSNodeTemplate
# ------------------------------------------------------
resource "kubernetes_manifest" "awsnodetemplate" {
  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1alpha1"
    "kind"       = "AWSNodeTemplate"
    "metadata" = {
      "name" = "default"
    }
    "spec" = {
      "amiFamily"       = "AL2023"
      "instanceProfile" = aws_iam_instance_profile.karpenter_node_profile.name
      "subnetSelector" = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
      "securityGroupSelector" = {
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    }
  }
}

# ------------------------------------------------------
# Default Provisioner - Karpenter watches for unschedulable pods using a Provisioner resource
# ------------------------------------------------------
resource "kubernetes_manifest" "default_provisioner" {
  manifest = {
    "apiVersion" = "karpenter.sh/v1alpha5"
    "kind"       = "Provisioner"
    "metadata" = {
      "name" = "default"
    }
    "spec" = {
      "requirements" = [
        {
          "key"      = "karpenter.sh/capacity-type"
          "operator" = "In"
          "values"   = ["spot", "on-demand"]
        }
      ]
      "limits" = {
        "resources" = {
          "cpu" = "1000"
        }
      }
      "providerRef" = {
        "name" = kubernetes_manifest.awsnodetemplate.manifest["metadata"]["name"]
      }
      "ttlSecondsAfterEmpty" = 30
    }
  }
}