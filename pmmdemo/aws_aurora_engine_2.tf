locals {
  rds_aurora_mysql_57_name = "rds-aurora-mysql-57"
}

resource "aws_rds_cluster" "rds_aurora_mysql_57" {
  apply_immediately    = true
  cluster_identifier   = local.rds_aurora_mysql_57_name
  count                = var.DBAAS > 0 ? 1 : 0
  database_name        = "pmmdemo"
  db_subnet_group_name = "${local.environment_name}-${local.rds_aurora_mysql_57_name}-db-subnet"
  engine               = "aurora-mysql"
  engine_version       = "5.7.mysql_aurora.2.11.3"
  master_password      = random_password.rds_aurora_mysql_57_password.result
  master_username      = "pmmdemo"
  skip_final_snapshot  = true
}

resource "random_password" "rds_aurora_mysql_57_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
