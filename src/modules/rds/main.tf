data "aws_region" "current" {}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.environment}-${var.purpose}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier = var.db_identifier

  engine         = "mysql"
  engine_version = var.engine_version

  instance_class = "db.${var.instance_class}"

  db_name  = var.db_name
  username = var.master_username

  # THIS replaces everything related to passwords
  manage_master_user_password = true

  allocated_storage     = var.storage_gb
  max_allocated_storage = var.max_storage_gb
  apply_immediately     = true

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  backup_retention_period = var.backup_retention_days

  storage_encrypted   = true
  skip_final_snapshot = true
  deletion_protection = false

  auto_minor_version_upgrade = true
  engine_lifecycle_support   = "open-source-rds-extended-support-disabled"
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }

  tags = {
    Name = "${var.environment}-${var.purpose}-rds"
  }
}

resource "aws_kms_key" "rds_backup" {
  count = var.environment == "prod" ? 1 : 0

  provider = aws.backup

  description = "KMS key for prod RDS automated backup replication"
}

resource "aws_db_instance_automated_backups_replication" "this" {
  count = var.environment == "prod" ? 1 : 0

  provider = aws.backup

  source_db_instance_arn = aws_db_instance.this.arn
  retention_period       = var.backup_retention_days
  kms_key_id             = aws_kms_key.rds_backup[0].arn
}

resource "aws_secretsmanager_secret_rotation" "this" {
  secret_id = aws_db_instance.this.master_user_secret[0].secret_arn

  rotation_rules {
    schedule_expression = var.secret_rotation_schedule
    duration            = "1h"
  }
}