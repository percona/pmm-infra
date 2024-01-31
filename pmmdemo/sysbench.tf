locals {
  sysbench_name = "sysbench"
}

module "sysbench" {
  source        = "./modules/ec2"
  server_name   = local.sysbench_name
  instance_type = "t3a.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
  ]
  user_data = templatefile("provision_scripts/sysbench.yml", {
    domain                                = var.pmm_domain
    environment_name                      = local.environment_name
    fqdn                                  = "${local.sysbench_name}.${aws_route53_zone.demo_local.name}"
    local_domain                          = "${local.environment_name}.local"
    mysql80_sysbench_password             = random_password.mysql80_sysbench_password.result
    mysql81_sysbench_password             = random_password.mysql81_sysbench_password.result
    name                                  = local.sysbench_name
    percona_group_replication_81_password = random_password.percona_group_replication_81_sysbench_password.result
    percona_xtradb_cluster_80_password    = random_password.percona_xtradb_cluster_80_sysbench_password.result
    pmm_admin_password                    = random_password.pmm_admin_pass.result
    pmm_server_endpoint                   = local.pmm_server_endpoint
    postgres_pmm_password                 = random_password.postgresql_13_pmm_password.result
    postgres_sysbench_password            = random_password.postgresql_13_sysbench_password.result
    proxysql_monitor_password             = random_password.proxysql_monitor.result
  })
}
