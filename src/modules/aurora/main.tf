# AI SUMMARISER PURPOSE

/*
data "aws_region" "current" {}

locals {
    name_prefix = "${var.environment}-${var.purpose}-${data.aws_region.current.region}"
  retain = var.removal_policy == "retain"
}

# ----------------------------
# IAM Role for Enhanced Monitoring
# ----------------------------
resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ----------------------------
# Subnet Group
# ----------------------------
resource "aws_db_subnet_group" "aurora" {
  name       = "${local.name_prefix}-aurora-subnets"
  subnet_ids = var.private_subnet_ids

  description = "Private subnets for Aurora PostgreSQL"
}

# ----------------------------
# Aurora Cluster (Serverless v2)
# ----------------------------
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = var.db_identifier

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  port           = var.port

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [var.security_group_id]

  storage_encrypted = true
  backup_retention_period = var.backup_retention_days

  iam_database_authentication_enabled = true
  enable_http_endpoint                = true

  serverlessv2_scaling_configuration {
    min_capacity = var.min_acu
    max_capacity = var.max_acu
  }

  # Performance Insights at cluster level for Serverless v2
  performance_insights_enabled = true

  # ✅ Let AWS create & rotate the password in Secrets Manager
  manage_master_user_password = true
  master_username             = var.db_username
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  copy_tags_to_snapshot = true
  skip_final_snapshot   = true
  deletion_protection   = false
}


# ----------------------------
# REQUIRED Writer Instance (CDK created this!)
# ----------------------------
resource "aws_rds_cluster_instance" "writer" {
  identifier         = var.writer_identifier
  cluster_identifier = aws_rds_cluster.aurora.id

  instance_class = "db.serverless"
  engine         = aws_rds_cluster.aurora.engine
  engine_version = aws_rds_cluster.aurora.engine_version

  monitoring_interval    = 60
  monitoring_role_arn    = aws_iam_role.rds_monitoring.arn
  promotion_tier         = 1

  depends_on = [aws_rds_cluster.aurora]
}
*/