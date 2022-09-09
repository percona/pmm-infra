resource "aws_db_instance" "pmmdemo_aws_mysql_engine_80" {
  identifier           = "pmmdemo-mysql"
  availability_zone    = "us-east-1f"
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t2.medium"
  db_name              = "pmmdemo"
  username             = "pmmdemo"
  password             = random_password.pmmdemo_aurora_57_password.result
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.database_subnet.name
}

resource "random_password" "pmmdemo_aws_mysql_engine_80" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
