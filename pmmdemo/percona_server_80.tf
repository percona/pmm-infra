locals {
  percona_server_80_name = "percona-server-80"
  count                  = 2 # source and replica
}

module "percona_server_80" {
  source        = "./modules/ec2"
  count         = local.count
  server_name   = "${local.percona_server_80_name}-${count.index}"
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  depends_on = [
    module.pmm_server
  ]

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.percona_server_80_user_data.*.rendered, count.index)
}

resource "random_password" "mysql80_root_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "mysql80_replica_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "mysql80_sysbench_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

data "template_file" "percona_server_80_user_data" {
  count    = local.count
  template = file("provision_scripts/percona_server_80.yml")
  vars = {
    environment_name          = local.environment_name
    fqdn                      = "${local.percona_server_80_name}-${count.index}.${aws_route53_zone.demo_local.name}"
    index                     = "${count.index}"
    local_domain              = "${local.environment_name}.local"
    mysql_replica_password    = random_password.mysql80_replica_password.result
    mysql_root_password       = random_password.mysql80_root_password.result
    mysql_sysbench_password   = random_password.mysql80_sysbench_password.result
    name                      = "${local.percona_server_80_name}-${count.index}"
    pmm_password              = random_password.pmm_admin_pass.result
    pmm_server_endpoint       = local.pmm_server_endpoint
    proxysql_monitor_password = random_password.proxysql_monitor.result
  }
}

module "percona_server_80_disk" {
  source      = "./modules/ebs"
  count       = local.count
  disk_name   = "percona-server-80"
  disk_size   = 256
  instance_id = module.percona_server_80[count.index].instance_id
}
