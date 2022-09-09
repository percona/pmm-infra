resource "aws_rds_cluster" "pmmdemo_aurora_57" {
  cluster_identifier  = "pmmdemo-aurora-cluster"
  engine              = "aurora-mysql"
  engine_version      = "5.7.mysql_aurora.2.10.2"
  database_name       = "pmmdemo"
  master_username     = "pmmdemo"
  master_password     = random_password.pmmdemo_aurora_57_password.result
  skip_final_snapshot = true
  apply_immediately   = true
}

resource "random_password" "pmmdemo_aurora_57_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
