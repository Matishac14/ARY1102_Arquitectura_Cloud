resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "ALB: HTTP desde Internet (solo listener :80)"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg-alb"
    Tier = "public"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP publico"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Salida hacia targets"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg-app"
  description = "EC2 App: solo trafico desde ALB (capa privada)"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg-app"
    Tier = "private-app"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_http_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP desde ALB"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Salida controlada via NAT (ECR, yum, MySQL)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "data" {
  name        = "${var.project_name}-sg-data"
  description = "EC2 MySQL: solo puerto 3306 desde App"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg-data"
    Tier = "private-data"
  })
}

resource "aws_vpc_security_group_ingress_rule" "data_mysql_from_app" {
  security_group_id            = aws_security_group.data.id
  description                  = "MySQL desde capa App"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_egress_rule" "data_all" {
  security_group_id = aws_security_group.data.id
  description       = "Salida minima (actualizaciones locales / VPC)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
