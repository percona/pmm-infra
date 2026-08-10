run "verify_ec2_instance_type" {
  command = plan

  module {
    source = "./modules/ec2"
  }

  variables {
    server_name     = "test-server"
    instance_type   = "t3.micro"
    subnet_id       = "subnet-123456"
    route53_id      = "Z123456"
    iam_role_name   = "test-role"
    security_groups = ["sg-123456"]
    user_data       = ""
  }

  assert {
    condition     = aws_instance.ec2.instance_type == "t3.micro"
    error_message = "Instance type was not correctly applied from variable"
  }
}
