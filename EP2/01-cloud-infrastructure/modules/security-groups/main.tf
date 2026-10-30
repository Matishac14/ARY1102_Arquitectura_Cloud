# SG-ALB: Internet → ALB :80/:443 (usado por AWS Load Balancer Controller via annotation)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "ALB Ingress: HTTP/HTTPS desde Internet"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-sg-alb", Tier = "public" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP publico"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS publico"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Hacia pods/nodos EKS"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# SG adicional del control plane (opcional / tagging)
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-sg-eks-cluster"
  description = "SG adicional cluster EKS"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-sg-eks-cluster", Tier = "private-app" })
}

resource "aws_vpc_security_group_egress_rule" "eks_cluster_all" {
  security_group_id = aws_security_group.eks_cluster.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# SG-EKS nodos/pods: trafico desde ALB + comunicacion interna
resource "aws_security_group" "eks_node" {
  name        = "${var.project_name}-sg-eks-node"
  description = "Nodos/pods EKS: ingreso desde ALB e interno"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-sg-eks-node", Tier = "private-app" })
}

resource "aws_vpc_security_group_ingress_rule" "eks_from_alb" {
  security_group_id            = aws_security_group.eks_node.id
  description                  = "Trafico desde ALB (target-type ip: puertos de pods)"
  ip_protocol                  = "tcp"
  from_port                    = 1
  to_port                      = 65535
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_node_self" {
  security_group_id            = aws_security_group.eks_node.id
  description                  = "Comunicacion nodo-a-nodo / pod-a-pod"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.eks_node.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_from_cluster_sg" {
  security_group_id            = aws_security_group.eks_node.id
  description                  = "Desde SG adicional del cluster"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_vpc_security_group_egress_rule" "eks_node_all" {
  security_group_id = aws_security_group.eks_node.id
  description       = "Egreso via NAT (ECR, RDS, APIs AWS)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# SG-RDS: solo 3306 desde nodos EKS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "RDS MySQL: solo 3306 desde EKS"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.project_name}-sg-rds", Tier = "private-data" })
}

resource "aws_vpc_security_group_ingress_rule" "rds_mysql_from_eks" {
  security_group_id            = aws_security_group.rds.id
  description                  = "MySQL desde capa App EKS"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.eks_node.id
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
