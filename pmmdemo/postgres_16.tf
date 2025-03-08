locals {
  postgresql_16_name = "postgresql-16"
}

module "postgresql_16" {
  source        = "./modules/ec2"
  server_name   = local.postgresql_16_name
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/postgres_16.yml", {
    name                       = local.postgresql_16_name,
    fqdn                       = "${local.postgresql_16_name}.${aws_route53_zone.demo_local.name}",
    local_domain               = "${local.environment_name}.local"
    pmm_password               = random_password.pmm_admin_pass.result,
    pmm_server_endpoint        = "pmm-server.${aws_route53_zone.demo_local.name}:443"
    postgres_pmm_password      = random_password.postgresql_16_pmm_password.result,
    postgres_sysbench_password = random_password.postgresql_16_sysbench_password.result,
    environment_name           = local.environment_name
    scripts_path               = local.scripts_path
  })

  depends_on = [
    module.pmm_server
  ]  
}

resource "random_password" "postgresql_16_pmm_password" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 4
  special     = false
}

resource "random_password" "postgresql_16_sysbench_password" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 4
  special     = false
}

module "postgresql_16_disk" {
  source      = "./modules/ebs"
  disk_name   = "postgresql-16-disk"
  disk_size   = 256
  instance_id = module.postgresql_16.instance_id
}
