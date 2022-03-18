module "mongo_42_rs_0" {
  source        = "../ec2"
  count         = var.count_of_chards
  server_name   = "${local.mongo_cluster_name}-rs-0-${count.index}"
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = var.security_groups

  user_data = templatefile(local.provision_scripts_path, {
    pmm_password        = var.pmm_password,
    name                = "${local.mongo_cluster_name}-rs-0-${count.index}",
    fqdn                = "${local.mongo_cluster_name}-rs-0-${count.index}.${var.route53_name}",
    pmm_server_endpoint = var.pmm_server_endpoint,
  })
}

module "mongo_42_rs_0_disk" {
  source      = "../ebs"
  count       = var.count_of_chards
  disk_name   = "${local.mongo_cluster_name}-rs-0-${count.index}"
  disk_size   = var.mongo_disk_size
  instance_id = module.mongo_42_rs_0[count.index].instance_id
}


module "mongo_42_rs_1" {
  source        = "../ec2"
  count         = var.count_of_chards
  server_name   = "${local.mongo_cluster_name}-rs-1-${count.index}"
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = var.security_groups

  user_data = templatefile(local.provision_scripts_path, {
    pmm_password        = var.pmm_password,
    name                = "${local.mongo_cluster_name}-rs-1-${count.index}",
    fqdn                = "${local.mongo_cluster_name}-rs-1-${count.index}.${var.route53_name}",
    pmm_server_endpoint = var.pmm_server_endpoint,
  })
}

module "mongo_42_rs_1_disk" {
  source      = "../ebs"
  count       = var.count_of_chards
  disk_name   = "${local.mongo_cluster_name}-rs-1-${count.index}"
  disk_size   = var.mongo_disk_size
  instance_id = module.mongo_42_rs_1[count.index].instance_id
}

module "mongo_42_cfg_0" {
  source        = "../ec2"
  count         = var.count_of_chards
  server_name   = "${local.mongo_cluster_name}-cfg-0-${count.index}"
  instance_type = "t3.small"
  subnet_id     = var.subnet_id
  route53_id    = var.route53_id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile(local.provision_scripts_path, {
    pmm_password        = random_password.pmm_admin_pass.result,
    name                = "${local.mongo_cluster_name}-cfg-0-${count.index}",
    fqdn                = "${local.mongo_cluster_name}-cfg-0-${count.index}.${aws_route53_zone.demo_local.name}",
    pmm_server_endpoint = local.pmm_server_endpoint,
  })
}

module "mongo_42_cfg_0_disk" {
  source      = "../ebs"
  count       = var.count_of_chards
  disk_name   = "${local.mongo_cluster_name}-cfg-0-${count.index}"
  disk_size   = var.mongo_config_disk_size
  instance_id = module.mongo_42_cfg_0[count.index].instance_id
}
