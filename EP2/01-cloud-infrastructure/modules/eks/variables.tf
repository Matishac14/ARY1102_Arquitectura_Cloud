variable "project_name" { type = string }
variable "cluster_name" { type = string }
variable "kubernetes_version" { type = string }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "cluster_additional_security_group_ids" { type = list(string) }
variable "node_security_group_ids" { type = list(string) }
variable "node_instance_types" { type = list(string) }
variable "node_ami_type" { type = string }
variable "node_disk_size_gb" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "node_desired_size" { type = number }
variable "enable_cluster_logging" { type = bool }
variable "enable_cloudwatch_observability_addon" { type = bool }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_oidc_provider" {
  type    = bool
  default = false
}
