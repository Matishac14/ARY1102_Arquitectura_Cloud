variable "project_name" { type = string }
variable "identifier" { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "db_name" { type = string }
variable "username" { type = string }
variable "password" {
  type      = string
  sensitive = true
}
variable "allocated_storage" { type = number }
variable "backup_retention_period" { type = number }
variable "subnet_ids" { type = list(string) }
variable "vpc_security_group_ids" { type = list(string) }
variable "tags" {
  type    = map(string)
  default = {}
}
