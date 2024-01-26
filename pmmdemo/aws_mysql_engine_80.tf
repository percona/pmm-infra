locals {
  rds_mysql_80_name = "rds_mysql_80"
}

resource "aws_db_instance" "pmmdemo_aws_mysql_engine_80" {
  allocated_storage    = 10
  availability_zone    = "us-east-1f"
  db_name              = "pmmdemo"
  db_subnet_group_name = "${local.environment_name}-${local.rds_mysql_80_name}-db-subnet"
  engine               = "mysql"
  engine_version       = "8.0.35"
  identifier           = local.rds_mysql_80_name
  instance_class       = "db.t4g.medium"
  password             = random_password.rds_mysql_80_password.result
  skip_final_snapshot  = true
  username             = "pmmdemo"
}

resource "random_password" "rds_mysql_80_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
