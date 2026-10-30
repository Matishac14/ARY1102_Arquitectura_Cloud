output "alb_security_group_id" { value = aws_security_group.alb.id }
output "eks_cluster_security_group_id" { value = aws_security_group.eks_cluster.id }
output "eks_node_security_group_id" { value = aws_security_group.eks_node.id }
output "rds_security_group_id" { value = aws_security_group.rds.id }
# Alias para claridad del enunciado (SG-APP = nodos EKS)
output "app_security_group_id" { value = aws_security_group.eks_node.id }
output "data_security_group_id" { value = aws_security_group.rds.id }
