locals {
  percona_server_81_name = "percona-server-81"
  count_81               = 2 # source and replica
}

module "percona_server_81" {
  source        = "./modules/ec2"
  count         = local.count_81
  server_name   = "${local.percona_server_81_name}-${count.index}"
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  depends_on = [
    module.pmm_server
  ]

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.percona_server_81_user_data.*.rendered, count.index)
}

resource "random_password" "mysql81_root_password" {
  length      = 8
}

resource "random_password" "mysql81_replica_password" {
  length      = 8
}

resource "random_password" "mysql81_sysbench_password" {
  length      = 8
}

data "template_file" "percona_server_81_user_data" {
  count    = local.count
  template = file("provision_scripts/percona_server_81.yml")
  vars = {
    name                      = "${local.percona_server_81_name}-${count.index}"
    fqdn                      = "${local.percona_server_81_name}-${count.index}.${aws_route53_zone.demo_local.name}"
    index                     = "${count.index}"
    pmm_password              = random_password.pmm_admin_pass.result
    mysql_root_password       = random_password.mysql81_root_password.result
    mysql_replica_password    = random_password.mysql81_replica_password.result
    mysql_sysbench_password   = random_password.mysql81_sysbench_password.result
    pmm_server_endpoint       = local.pmm_server_endpoint
    proxysql_monitor_password = random_password.proxysql_monitor.result
    environment_name          = local.environment_name
  }
}

module "percona_server_81_disk" {
  source      = "./modules/ebs"
  count       = local.count_81
  disk_name   = "percona-server-81"
  disk_size   = 256
  instance_id = module.percona_server_81[count.index].instance_id
}
