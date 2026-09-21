locals {
  user_data = templatefile("${path.module}/templates/mysql-user-data.sh.tftpl", {
    init_sql         = var.init_sql
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    db_root_password = var.db_root_password
  })
}

resource "aws_instance" "mysql" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile_name
  key_name                    = var.key_name
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size_gb
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ec2-mysql"
    Role = "database"
  })

  # Destroy-then-create (evita InvalidIPAddress.InUse con IP fija).
  lifecycle {
    create_before_destroy = false
    ignore_changes        = [ami]
  }
}

resource "aws_backup_vault" "mysql" {
  name = "${var.project_name}-mysql-vault"

  tags = merge(var.tags, {
    Name = "${var.project_name}-mysql-vault"
  })
}

resource "aws_backup_plan" "mysql" {
  name = "${var.project_name}-mysql-daily"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.mysql.name
    schedule          = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-mysql-backup-plan"
  })
}

resource "aws_backup_selection" "mysql" {
  name         = "${var.project_name}-mysql-selection"
  iam_role_arn = var.backup_role_arn
  plan_id      = aws_backup_plan.mysql.id

  resources = [
    aws_instance.mysql.arn
  ]
}
