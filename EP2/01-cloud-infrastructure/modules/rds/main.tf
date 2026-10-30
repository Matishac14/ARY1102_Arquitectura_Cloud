resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-rds-subnets"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.project_name}-rds-subnets" })
}

resource "aws_db_instance" "mysql" {
  identifier     = var.identifier
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = 3306

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  copy_tags_to_snapshot   = true
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true

  # Learner Lab: evitar Parameter Groups / Option Groups custom si el SCP los limita
  auto_minor_version_upgrade = true

  tags = merge(var.tags, {
    Name = var.identifier
    Tier = "private-data"
  })
}
