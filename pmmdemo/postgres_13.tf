locals {
  postgresql_13_name = "postgresql-13"
}


module "postgresql_13" {
  source        = "./modules/ec2"
  server_name   = local.postgresql_13_name
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/postgres_13.yml", {
    name                       = local.postgresql_13_name,
    fqdn                       = "${local.postgresql_13_name}.${aws_route53_zone.demo_local.name}",
    pmm_password               = random_password.pmm_admin_pass.result,
    pmm_server_endpoint        = "pmm-server.${aws_route53_zone.demo_local.name}:443"
    postgres_pmm_password      = random_password.postgresql_13_pmm_password.result,
    postgres_sysbench_password = random_password.postgresql_13_sysbench_password.result,
    environment_name           = local.environment_name
  })

  depends_on = [
    module.pmm_server
  ]  
}

resource "random_password" "postgresql_13_pmm_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

resource "random_password" "postgresql_13_sysbench_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

module "postgresql_13_disk" {
  source      = "./modules/ebs"
  disk_name   = "postgresql-13-disk"
  disk_size   = 256
  instance_id = module.postgresql_13.instance_id
}
