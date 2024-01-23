module "percona_group_replication_81" {
  source        = "./modules/ec2"
  count         = local.percona_group_replication_81_count
  server_name = "${local.percona_group_replication_81_name}-${count.index + 1}"
  instance_type = "t3a.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.percona_group_replication_81_user_data.*.rendered, count.index)
}

data "template_file" "percona_group_replication_81_user_data" {
  count    = local.percona_group_replication_81_count
  template = file("provision_scripts/percona_group_replication_81.yml")
  vars = {
    environment_name                = local.environment_name
    fqdn                            = "${local.percona_group_replication_81_name}-${count.index + 1}.${aws_route53_zone.demo_local.name}"
    index                           = "${count.index + 1}"
    local_domain                    = "${local.environment_name}.local"
    mysql_replica_password          = random_password.mysql81_replica_password.result
    mysql_root_password             = random_password.percona_group_replication_81_root_password.result
    mysql_sysbench_password         = random_password.percona_group_replication_81_sysbench_password.result
    name                            = "${local.percona_group_replication_81_name}-${count.index + 1}"
    percona_group_replication_uuid  = random_uuid.percona_group_replication_81_uuid.result
    pmm_password                    = random_password.pmm_admin_pass.result
    pmm_server_endpoint             = local.pmm_server_endpoint
    proxysql_monitor_password       = random_password.proxysql_monitor.result
  }
}

module "percona_group_replication_81_disk" {
  source      = "./modules/ebs"
  count       = local.percona_group_replication_81_count
  disk_name   = "percona_group_replication_datadir-${count.index}"
  disk_size   = 64
  instance_id = module.percona_group_replication_81["${count.index}"].instance_id
}

resource "random_password" "percona_group_replication_81_root_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "percona_group_replication_81_sysbench_password" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_uuid" "percona_group_replication_81_uuid" {  
}

locals {
  percona_group_replication_81_name  = "percona-group-replication"
  percona_group_replication_81_count = 3
}
