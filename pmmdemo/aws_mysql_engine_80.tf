locals {
  rds_mysql_80_name = "rds-mysql-80"
  rds_mysql_username = "sysbench"
}

resource "aws_db_instance" "rds_mysql_80" {
  allocated_storage          = 20
  availability_zone          = "us-east-1f"
  count                      = var.DBAAS > 0 ? 1 : 0
  db_name                    = "sysbench"
  db_subnet_group_name       = "${local.environment_name}-aws-db-subnet"
  engine                     = "mysql"
  engine_version             = "8.0"
  auto_minor_version_upgrade = true
  identifier                 = local.rds_mysql_80_name
  instance_class             = "db.t4g.medium"
  password                   = random_password.rds_mysql_80_password.result
  skip_final_snapshot        = true
  username                   = local.rds_mysql_username
}

resource "random_password" "rds_mysql_80_password" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 4
  special     = false
}
