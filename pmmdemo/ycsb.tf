locals {
  ycsb_name = "ycsb"
}

module "ycsb" {
  source        = "./modules/ec2"
  server_name   = local.ycsb_name
  instance_type = "t3a.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
  ]
  user_data = templatefile("provision_scripts/ycsb.yml", {
    domain                = var.pmm_domain
    environment_name      = local.environment_name
    fqdn                  = "${local.ycsb_name}.${aws_route53_zone.demo_local.name}"
    local_domain          = "${local.environment_name}.local"
    mongodb_ycsb_password = random_password.mongodb_ycsb_password.result
    name                  = local.ycsb_name
    pmm_admin_password    = random_password.pmm_admin_pass.result
    pmm_server_endpoint   = local.pmm_server_endpoint
  })
}

resource "random_password" "mongodb_ycsb_password" {
  length      = 30
  upper       = true
  numeric     = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}
