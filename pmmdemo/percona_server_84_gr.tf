module "percona_server_84_gr" {
  source        = "./modules/ec2"
  count         = local.percona_server_84_gr_count
  server_name = "${local.percona_server_84_gr_name}-${count.index + 1}"
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.percona_server_84_gr_user_data.*.rendered, count.index)
}

data "template_file" "percona_server_84_gr_user_data" {
  count    = local.percona_server_84_gr_count
  template = file("provision_scripts/percona_server_84_gr.yml")
  vars = {
    environment_name          = local.environment_name
    fqdn                      = "${local.percona_server_84_gr_name}-${count.index + 1}.${aws_route53_zone.demo_local.name}"
    index                     = "${count.index + 1}"
    local_domain              = "${local.environment_name}.local"
    mysql_replica_password    = random_password.mysql84_replica_password.result
    mysql_root_password       = random_password.percona_server_84_gr_root_password.result
    mysql_sysbench_password   = random_password.percona_server_84_gr_sysbench_password.result
    name                      = "${local.percona_server_84_gr_name}-${count.index + 1}"
    percona_server_gr_uuid    = random_uuid.percona_server_84_gr_uuid.result
    pmm_password              = random_password.pmm_admin_pass.result
    pmm_server_endpoint       = local.pmm_server_endpoint
    proxysql_monitor_password = random_password.proxysql_monitor.result
    scripts_path              = local.scripts_path
  }
}

module "percona_server_84_gr_disk" {
  source      = "./modules/ebs"
  count       = local.percona_server_84_gr_count
  disk_name   = "percona_gr_datadir-${count.index}"
  disk_size   = 64
  instance_id = module.percona_server_84_gr["${count.index}"].instance_id
}

resource "random_password" "percona_server_84_gr_root_password" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 4
  special     = false
}

resource "random_password" "percona_server_84_gr_sysbench_password" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 4
  special     = false
}

resource "random_uuid" "percona_server_84_gr_uuid" {  
}

locals {
  percona_server_84_gr_name  = "percona-server-84-gr"
  percona_server_84_gr_count = 3
}
