locals {
  percona_server_80_name = "percona-server-80"
  count                  = 2 # source and replica
}


module "percona_server_80" {
  source        = "./modules/ec2"
  count         = local.count
  server_name   = "${local.percona_server_80_name}-${count.index}"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = element(data.template_file.percona_server_80_user_data.*.rendered, count.index)
}

variable "hostnames" {
  default = {
    "0" = "example1.org"
    "1" = "example2.net"
  }
}

resource "random_password" "mysql80_root_password" {
  length  = 30
  special = true
}

resource "random_password" "mysql80_replica_password" {
  length  = 30
  special = true
}

resource "random_password" "mysql80_sysbench_password" {
  length  = 30
  special = true
}

data "template_file" "percona_server_80_user_data" {
  count    = local.count
  template = file("provision_scripts/percona_server_80.yml")
  vars = {
    name                    = "${local.percona_server_80_name}-${count.index}"
    fqdn                    = "${local.percona_server_80_name}-${count.index}.demo.local"
    index                   = "${count.index}"
    pmm_password            = random_password.pmm_admin_pass.result
    mysql_root_password     = random_password.mysql80_root_password.result
    mysql_replica_password  = random_password.mysql80_replica_password.result
    mysql_sysbench_password = random_password.mysql80_sysbench_password.result
  }
}

module "percona_server_80_disk" {
  source      = "./modules/ebs"
  count       = local.count
  disk_name   = "percona-server-80"
  disk_size   = "256"
  instance_id = module.percona_server_80[count.index].instance_id
}

// TODO encrypt state or don't store plain text
output "pmm_password" {
  sensitive = true
  value     = random_password.pmm_admin_pass.result
}
