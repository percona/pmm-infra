locals {
  percona_xtradb_cluster_80_name  = "percona-xtradb-cluster"
  percona_xtradb_cluster_80_count = 3
}


module "percona_xtradb_cluster_80" {
  source        = "./modules/ec2"
  count         = local.percona_xtradb_cluster_80_count
  server_name   = "${local.percona_xtradb_cluster_80_name}-${count.index}"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.percona_xtradb_cluster_80_user_data.*.rendered, count.index)
}

resource "random_password" "percona_xtradb_cluster_80_root_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

resource "random_password" "percona_xtradb_cluster_80_sysbench_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

data "template_file" "percona_xtradb_cluster_80_user_data" {
  count    = local.percona_xtradb_cluster_80_count
  template = file("provision_scripts/percona_xtradb_cluster_80.yml")
  vars = {
    name                      = "${local.percona_xtradb_cluster_80_name}-${count.index}"
    fqdn                      = "${local.percona_xtradb_cluster_80_name}-${count.index}.${aws_route53_zone.demo_local.name}"
    index                     = "${count.index}"
    pmm_password              = random_password.pmm_admin_pass.result
    mysql_root_password       = random_password.percona_xtradb_cluster_80_root_password.result
    mysql_sysbench_password   = random_password.percona_xtradb_cluster_80_sysbench_password.result
    pmm_server_endpoint       = local.pmm_server_endpoint
    proxysql_monitor_password = random_password.proxysql_monitor.result
  }
}

module "percona_xtradb_cluster_80_disk" {
  source      = "./modules/ebs"
  count       = local.percona_xtradb_cluster_80_count
  disk_name   = "percona_xtradb_cluster_80-${count.index}"
  disk_size   = 64
  instance_id = module.percona_xtradb_cluster_80[count.index].instance_id
}
