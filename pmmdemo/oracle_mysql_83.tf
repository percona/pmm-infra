locals {
  oracle_mysql_83_name = "oracle-mysql-83"
  oracle_count_83      = 2 # source and replica
}

module "oracle_mysql_83" {
  source        = "./modules/ec2"
  count         = local.oracle_count_83
  server_name   = "${local.oracle_mysql_83_name}-${count.index}"
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  depends_on = [
    module.pmm_server
  ]

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.oracle_mysql_83_user_data.*.rendered, count.index)
}

resource "random_password" "oracle_mysql_83_root_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "oracle_mysql_83_replica_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "oracle_mysql_83_sysbench_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

data "template_file" "oracle_mysql_83_user_data" {
  count    = local.count
  template = file("provision_scripts/oracle_mysql_83.yml")
  vars = {
    environment_name          = local.environment_name
    fqdn                      = "${local.oracle_mysql_83_name}-${count.index}.${aws_route53_zone.demo_local.name}"
    index                     = "${count.index}"
    local_domain              = "${local.environment_name}.local"
    mysql_replica_password    = random_password.oracle_mysql_83_replica_password.result
    mysql_root_password       = random_password.oracle_mysql_83_root_password.result
    mysql_sysbench_password   = random_password.oracle_mysql_83_sysbench_password.result
    name                      = "${local.oracle_mysql_83_name}-${count.index}"
    pmm_password              = random_password.pmm_admin_pass.result
    pmm_server_endpoint       = local.pmm_server_endpoint
    proxysql_monitor_password = random_password.proxysql_monitor.result
  }
}

module "oracle_mysql_83_disk" {
  source      = "./modules/ebs"
  count       = local.oracle_count_83
  disk_name   = "oracle-mysql-83-datadir"
  disk_size   = 256
  instance_id = module.oracle_mysql_83[count.index].instance_id
}
