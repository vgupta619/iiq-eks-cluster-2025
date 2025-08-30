/*
1. Uses private subnets only
2. Creates the EKS cluster (private endpoint)
3. Adds a tiny bootstrap managed node group (1 node) just to run Karpenter controller
4. Enables IRSA (OIDC provider)
5. Creates the IAM role + instance profile that Karpenter will use for the nodes it provisions
6. Creates a node Security Group you can reference from Karpenter
7. Exposes the outputs you’ll need (endpoint, CA, OIDC, SGs, roles)
*/

locals {
  tags = merge(var.tags, {
    "eks:cluster"                               = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# ---------------------------
# EKS Cluster IAM Role
# ---------------------------
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_controller" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_VPCResourceController"
}

# ---------------------------
# EKS Cluster (private endpoint)
# ---------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.eks_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  tags = local.tags

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Data sources used by kubernetes/helm providers and outputs
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

# ---------------------------
# Node security group (nodes created by bootstrap + karpenter will use this SG)
# ---------------------------
resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS nodes (bootstrap & karpenter)"
  vpc_id      = var.vpc_id
  tags        = local.tags
}

# Egress all (so nodes can pull images via NAT)
resource "aws_security_group_rule" "nodes_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.nodes.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Control-plane -> nodes (kubelet ephemeral ports)
resource "aws_security_group_rule" "cp_to_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.nodes.id
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# Nodes -> control-plane (HTTPS)
resource "aws_security_group_rule" "nodes_to_cp" {
  type                     = "egress"
  security_group_id        = aws_security_group.nodes.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# ---------------------------
# OIDC Provider for IRSA
# ---------------------------
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

# ---------------------------
# Bootstrap managed node group (small) - optional
# ---------------------------
resource "aws_iam_role" "bootstrap_node_role" {
  count = var.enable_bootstrap_node_group ? 1 : 0
  name  = "${var.cluster_name}-bootstrap-node-role"

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

resource "aws_iam_role_policy_attachment" "bootstrap_eks_worker" {
  count      = var.enable_bootstrap_node_group ? 1 : 0
  role       = aws_iam_role.bootstrap_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "bootstrap_ecr" {
  count      = var.enable_bootstrap_node_group ? 1 : 0
  role       = aws_iam_role.bootstrap_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "bootstrap_cni" {
  count      = var.enable_bootstrap_node_group ? 1 : 0
  role       = aws_iam_role.bootstrap_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# SSM => allow Session Manager for bootstrap nodes
resource "aws_iam_role_policy_attachment" "bootstrap_ssm" {
  count      = var.enable_bootstrap_node_group ? 1 : 0
  role       = aws_iam_role.bootstrap_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Need a tiny bootstrap node group in your EKS module even if you’re using Karpenter as a separate module
resource "aws_eks_node_group" "bootstrap" {
  count           = var.enable_bootstrap_node_group ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-bootstrap"
  node_role_arn   = aws_iam_role.bootstrap_node_role[0].arn
  subnet_ids      = var.private_subnet_ids
  ami_type        = "AL2_x86_64"
  instance_types  = var.bootstrap_instance_types
  capacity_type   = var.capacity_type

  scaling_config {
    desired_size = var.bootstrap_desired_size
    min_size     = var.bootstrap_min_size
    max_size     = var.bootstrap_max_size
  }

  # optional remote_access only if a key is provided
  dynamic "remote_access" {
    for_each = var.bootstrap_ssh_key_name == null ? [] : [var.bootstrap_ssh_key_name]
    content {
      ec2_ssh_key = remote_access.value
    }
  }

  tags = local.tags

  depends_on = [aws_iam_role_policy_attachment.bootstrap_eks_worker]
}

# ---------------------------
# EKS managed add-ons (we keep them light; full add-on install via separate module if preferred)
# ---------------------------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "PRESERVE"
}

# if you prefer the EBS CSI installed as addon via EKS-managed addon:
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Federated = aws_iam_openid_connect_provider.oidc.arn },
      Action    = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-ebs-csi-controller"
        }
      }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn
}

# ---------------------------
# Kubernetes provider configuration (for any in-module Helm usage later)
# ---------------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}