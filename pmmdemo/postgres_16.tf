locals {
  postgres_16_name = "postgres-16"
  count              = 2
}


module "postgres_16" {
  count         = local.count
  instance_type = "t3a.medium"
  route53_id    = aws_route53_zone.demo_local.id
  server_name   = "${local.postgres_16_name}-${count.index}"
  source        = "./modules/ec2"
  subnet_id     = aws_subnet.pmmdemo_private.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/postgres_16.yml", {
    environment_name           = local.environment_name
    fqdn                       = "${local.postgres_16_name}.${count.index}.${aws_route53_zone.demo_local.name}",
    index                     = "${count.index}"
    local_domain              = "${local.environment_name}.local"
    name                       = "${local.postgres_16_name}-${count.index}",
    pmm_password               = random_password.pmm_admin_pass.result,
    pmm_server_endpoint        = "pmm-server.${aws_route53_zone.demo_local.name}:443"
    postgres_16_pmm_password      = random_password.postgres_16_pmm_password.result,
    postgres_16_sysbench_password = random_password.postgres_16_sysbench_password.result,

  })

  depends_on = [
    module.pmm_server
  ]  
}

resource "random_password" "postgres_16_pmm_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "postgres_16_sysbench_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

module "postgres_16_disk" {
  count       = local.count
  disk_name   = "postgres-16-disk"
  disk_size   = 256
  instance_id = module.postgresl_16[count.index].instance_id
  source      = "./modules/ebs"
}
