locals {
  postgres_13 = "postgres-13"
}


module "postgres_13" {
  source        = "./modules/ec2"
  server_name   = local.postgres_13
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/postgres_13.yml", {
    name                  = local.postgres_13,
    fqdn                  = "${local.postgres_13}.${aws_route53_zone.demo_local.name}",
    postgres_pmm_password = random_password.postgres_pmm_password.result,
    pmm_password          = random_password.pmm_admin_pass.result,
    pmm_server_endpoint   = "pmm-server.${aws_route53_zone.demo_local.name}:443"

  })
}

resource "random_password" "postgres_pmm_password" {
  length  = 30
  special = false
  upper   = true
  number  = true
}

module "postgres_13_disk" {
  source      = "./modules/ebs"
  disk_name   = "postgres_13"
  disk_size   = "256"
  instance_id = module.postgres_13.instance_id
}
