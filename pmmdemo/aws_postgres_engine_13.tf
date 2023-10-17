resource "aws_db_instance" "pmmdemo_postgres_13" {
  identifier           = "pmmdemo-postgres"
  engine               = "postgres"
  engine_version       = "13.10"
  instance_class       = "db.m5.large"
  allocated_storage    = 10
  db_name              = "pmmdemo"
  username             = "pmmdemo"
  password             = random_password.pmmdemo_postgres_13_password.result
  skip_final_snapshot  = true
  apply_immediately    = true
  db_subnet_group_name = "${local.environment_name}-db-subnet"
}

resource "random_password" "pmmdemo_postgres_13_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
