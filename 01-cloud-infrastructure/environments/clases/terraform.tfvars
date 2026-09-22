# Variables del workspace clases (versionadas para GitHub Actions).
# Credenciales: no van aquí. Local → AWS_PROFILE=clases | Actions → Secrets.
aws_region            = "us-east-1"
aws_profile           = ""
project_name          = "freshbox-ep1"
environment           = "clases"
key_name              = "vockey"
instance_profile_name = "LabInstanceProfile"
lab_role_name         = "LabRole"
instance_type         = "t4g.small"
asg_min_size          = 2
asg_max_size          = 4
asg_desired_capacity  = 2
root_volume_size_gb   = 20
db_name               = "freshbox"
db_user               = "alumno"
db_password           = "alumno123"
db_root_password      = "root123"
