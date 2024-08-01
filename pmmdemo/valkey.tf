locals {
  valkey_name = "valkey"
}

module "valkey" {
  source        = "./modules/ec2"
  server_name   = local.valkey_name
  instance_type = "t3a.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
  ]
  user_data = templatefile("provision_scripts/valkey.yml", {
    domain                  = var.pmm_domain
    environment_name        = local.environment_name
    fqdn                    = "${local.valkey_name}.${aws_route53_zone.demo_local.name}"
    local_domain            = "${local.environment_name}.local"
    name                    = local.valkey_name
    pmm_admin_password      = random_password.pmm_admin_pass.result
    pmm_server_endpoint     = local.pmm_server_endpoint
    valkey_primary_password = random_password.valkey_primary_password.result
  })
}

resource "random_password" "valkey_primary_password" {
  length      = 30
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}
