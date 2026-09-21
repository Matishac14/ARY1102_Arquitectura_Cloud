output "instance_id" {
  value = aws_instance.mysql.id
}

output "private_ip" {
  value = aws_instance.mysql.private_ip
}

output "backup_vault_name" {
  value = aws_backup_vault.mysql.name
}

output "backup_plan_id" {
  value = aws_backup_plan.mysql.id
}
