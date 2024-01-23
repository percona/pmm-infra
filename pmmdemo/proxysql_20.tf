locals {
  proxysql_name = "proxysql"
}

module "proxysql" {
  source        = "./modules/ec2"
  server_name   = local.proxysql_name
  instance_type = "t3a.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
  ]
  user_data = templatefile("provision_scripts/proxysql_20.yml", {
    domain                                = var.pmm_domain
    environment_name                      = local.environment_name
    fqdn                                  = "${local.proxysql_name}.${aws_route53_zone.demo_local.name}"
    local_domain                          = "${local.environment_name}.local"
    name                                  = local.proxysql_name
    percona_group_replication_81_password = random_password.percona_group_replication_81_sysbench_password.result
    percona_server_80_password            = random_password.mysql80_sysbench_password.result
    percona_server_81_password            = random_password.mysql81_sysbench_password.result
    percona_xtradb_cluster_80_password    = random_password.percona_xtradb_cluster_80_sysbench_password.result
    pmm_admin_password                    = random_password.pmm_admin_pass.result
    pmm_server_endpoint                   = local.pmm_server_endpoint
    proxysql_admin_password               = random_password.proxysql_admin.result
    proxysql_monitor_password             = random_password.proxysql_monitor.result
  })

  depends_on = [
    module.pmm_server,
    module.percona_server_80,
    module.percona_server_81,
    module.percona_xtradb_cluster_80,
    module.percona_group_replication_81
  ]
}

resource "random_password" "proxysql_monitor" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}

resource "random_password" "proxysql_admin" {
  length      = 8
  min_lower   = 0
  min_numeric = 0
  min_special = 0
  min_upper   = 8
}
