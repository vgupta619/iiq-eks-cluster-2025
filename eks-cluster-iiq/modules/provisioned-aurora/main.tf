resource "aws_security_group" "aurora" {
  name        = "aurora-prod-sg"
  description = "Aurora SG (prod)"
  vpc_id      = var.vpc_id
}

# Ingress: allow from EKS nodes
resource "aws_security_group_rule" "allow_from_nodes" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.aurora.id
  source_security_group_id = var.eks_nodes_sg_id
}

resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-prod-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-prod-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"
  master_username         = "admin"
  master_password         = "SuperSecret123"
  vpc_security_group_ids  = [aws_security_group.aurora.id]
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
}

# -----------------------
# CloudWatch Alarms
# -----------------------

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "aurora-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

# Freeable Memory Alarm
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  alarm_name          = "aurora-low-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 200   # 200 MB

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

# Database Connections Alarm
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "aurora-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 90

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

# Replica Lag Alarm (if using Aurora replicas)
resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  alarm_name          = "aurora-replica-lag-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100 # seconds

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

