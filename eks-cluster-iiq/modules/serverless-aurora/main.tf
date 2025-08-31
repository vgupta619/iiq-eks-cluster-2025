resource "aws_security_group" "aurora" {
  name        = var.aurora_sg
  description = "Aurora SG (non-prod)"
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
  name       = var.aurora_db_sg
  subnet_ids = var.private_subnet_ids
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = var.aurora_cluster_identifier
  engine                 = "aurora-mysql"
  engine_version         = var.engine_version
  master_username        = var.master_username
  master_password        = var.master_password
  vpc_security_group_ids = [aws_security_group.aurora.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora.name

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 4 # can scale up to 4 ACUs means 8GB RAM
  }
}

# -----------------------
# CloudWatch Alarms
# -----------------------

# CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.aurora_cluster_identifier}-cpu-high"
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

# Freeable Memory
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  alarm_name          = "${var.aurora_cluster_identifier}-low-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 200000000 # 200 MB

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

# Database Connections
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "${var.aurora_cluster_identifier}-high-connections"
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

# Aurora Serverless v2 Capacity Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "serverless_capacity" {
  alarm_name          = "${var.aurora_cluster_identifier}-capacity-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ServerlessDatabaseCapacity"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 3.5 # warn if capacity near max (max_capacity = 4)

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

