module "mongo_60_rs_0" {
  source        = "../ec2"
  count         = var.count_of_shards
  server_name   = "${local.mongo_cluster_name}-rs-0-${count.index}"
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = var.security_groups

  user_data = templatefile(local.provision_script_shard, {
    pmm_password                  = var.pmm_password,
    name                          = "${local.mongo_cluster_name}-rs-0-${count.index}",
    fqdn                          = "${local.mongo_cluster_name}-rs-0-${count.index}.${var.route53_name}",
    pmm_server_endpoint           = var.pmm_server_endpoint,
    replica_set_name              = "shard-0",
    shard_number                  = 0,
    route53_name                  = var.route53_name,
    mongodb_60_keyfile            = random_password.mongodb_60_keyfile.result,
    mongodb_60_pmm_user_password  = random_password.mongodb_60_pmm_user_password.result,
    mongodb_60_pmm_admin_password = random_password.mongodb_60_pmm_admin_password.result,
  })
}

module "mongo_60_rs_0_disk" {
  source      = "../ebs"
  count       = var.count_of_shards
  disk_name   = "${local.mongo_cluster_name}-rs-0-${count.index}"
  disk_size   = var.mongo_disk_size
  instance_id = module.mongo_60_rs_0[count.index].instance_id
}


module "mongo_60_rs_1" {
  source        = "../ec2"
  count         = var.count_of_shards
  server_name   = "${local.mongo_cluster_name}-rs-1-${count.index}"
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = var.security_groups

  user_data = templatefile(local.provision_script_shard, {
    pmm_password                  = var.pmm_password,
    name                          = "${local.mongo_cluster_name}-rs-1-${count.index}",
    fqdn                          = "${local.mongo_cluster_name}-rs-1-${count.index}.${var.route53_name}",
    pmm_server_endpoint           = var.pmm_server_endpoint,
    replica_set_name              = "shard-1",
    shard_number                  = 1,
    route53_name                  = var.route53_name,
    mongodb_60_keyfile            = random_password.mongodb_60_keyfile.result,
    mongodb_60_pmm_user_password  = random_password.mongodb_60_pmm_user_password.result,
    mongodb_60_pmm_admin_password = random_password.mongodb_60_pmm_admin_password.result,
  })
}

module "mongo_60_rs_1_disk" {
  source      = "../ebs"
  count       = var.count_of_shards
  disk_name   = "${local.mongo_cluster_name}-rs-1-${count.index}"
  disk_size   = var.mongo_disk_size
  instance_id = module.mongo_60_rs_1[count.index].instance_id
}

module "mongo_60_cfg" {
  source        = "../ec2"
  count         = var.count_of_shards
  server_name   = "${local.mongo_cluster_name}-cfg-${count.index}"
  instance_type = var.config_instance_type
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = var.security_groups

  user_data = templatefile(local.provision_script_cfg, {
    pmm_password                  = var.pmm_password,
    name                          = "${local.mongo_cluster_name}-cfg-${count.index}",
    fqdn                          = "${local.mongo_cluster_name}-cfg-${count.index}.${var.route53_name}",
    pmm_server_endpoint           = var.pmm_server_endpoint,
    replica_set_name              = "cfg",
    route53_name                  = var.route53_name,
    mongodb_60_keyfile            = random_password.mongodb_60_keyfile.result,
    mongodb_60_pmm_user_password  = random_password.mongodb_60_pmm_user_password.result,
    mongodb_60_pmm_admin_password = random_password.mongodb_60_pmm_admin_password.result,
  })
}

module "mongo_60_cfg_disk" {
  source      = "../ebs"
  count       = var.count_of_shards
  disk_name   = "${local.mongo_cluster_name}-cfg-${count.index}"
  disk_size   = var.mongo_config_disk_size
  instance_id = module.mongo_60_cfg[count.index].instance_id
}

module "mongo_60_mongos" {
  source        = "../ec2"
  count         = var.count_of_mongos
  server_name   = "${local.mongo_cluster_name}-mongos-${count.index}"
  instance_type = var.mongos_instance_type
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = var.security_groups

  user_data = templatefile(local.provision_script_mongos, {
    pmm_password                  = var.pmm_password,
    name                          = "${local.mongo_cluster_name}-mongos-${count.index}",
    fqdn                          = "${local.mongo_cluster_name}-mongos-${count.index}.${var.route53_name}",
    pmm_server_endpoint           = var.pmm_server_endpoint,
    route53_name                  = var.route53_name,
    replica_set_name              = "cfg",
    mongodb_60_keyfile            = random_password.mongodb_60_keyfile.result,
    mongodb_60_pmm_admin_password = random_password.mongodb_60_pmm_admin_password.result,
    mongodb_60_pmm_user_password  = random_password.mongodb_60_pmm_user_password.result,
    mongodb_ycsb_password         = var.mongodb_ycsb_password,
  })
}

resource "random_password" "mongodb_60_pmm_user_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

resource "random_password" "mongodb_60_pmm_admin_password" {
  length  = 30
  special = false
  upper   = true
  numeric = true
}

// TODO it's better use x.509 cert auth
resource "random_password" "mongodb_60_keyfile" {
  length  = 1000
  special = false
  upper   = true
  numeric = true
}

output "mongodb_60_pmm_user_password" {
  value     = random_password.mongodb_60_pmm_user_password.result
  sensitive = true
}

output "mongodb_60_pmm_admin_password" {
  value     = random_password.mongodb_60_pmm_admin_password.result
  sensitive = true
}
