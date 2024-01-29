locals {
  rds_postgresql_13_name = "rds_postgresql_13"
}

resource "aws_db_instance" "rds_postgresql_13" {
  allocated_storage    = 10
  apply_immediately    = true
  db_name              = "pmmdemo"
  db_subnet_group_name = "${local.environment_name}-${local.rds_postgresql_13_name}-db-subnet"
  engine               = "postgres"
  engine_version       = "13.10"
  identifier           = local.rds_postgresql_13_name
  instance_class       = "db.m5.large"
  password             = random_password.rds_postgresql_13_password.result
  skip_final_snapshot  = true
  username             = "pmmdemo"
}

resource "random_password" "rds_postgresql_13_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
