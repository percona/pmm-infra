locals {
  proxysql_name = "proxysql"
}

module "proxysql" {
  source        = "./modules/ec2"
  server_name   = local.proxysql_name
  instance_type = "t3.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
  ]
  user_data = templatefile("provision_scripts/proxysql_20.yml", {
    name                               = local.proxysql_name
    domain                             = var.pmm_domain
    pmm_admin_password                 = random_password.pmm_admin_pass.result
    pmm_server_endpoint                = local.pmm_server_endpoint
    fqdn                               = "${local.proxysql_name}.${aws_route53_zone.demo_local.name}"
    proxysql_monitor_password          = random_password.proxysql_monitor.result
    proxysql_admin_password            = random_password.proxysql_admin.result
    percona_server_80_password         = random_password.mysql80_sysbench_password.result
    percona_xtradb_cluster_80_password = random_password.percona_xtradb_cluster_80_sysbench_password.result
  })

  depends_on = [
    module.pmm_server,
    module.percona_server_80,
    module.percona_xtradb_cluster_80
  ]
}

resource "random_password" "proxysql_monitor" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

resource "random_password" "proxysql_admin" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}
