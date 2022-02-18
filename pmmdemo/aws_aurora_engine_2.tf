resource "aws_db_instance" "pmmdemo_aurora_57" {
  allocated_storage    = 10
  engine               = "Aurora"
  engine_version       = "2"
  instance_class       = "db.t2.medium"
  name                 = "pmmdemo"
  username             = "pmmdemo"
  password             = random_password.pmmdemo_aurora_57_password.result
  skip_final_snapshot  = true
}

resource "random_password" "pmmdemo_aurora_57_password" {
  length      = 30
  special     = true
  upper       = true
  number      = true
}
