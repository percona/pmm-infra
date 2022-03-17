locals {
  mongo_cluster_name = "mongo_42"
  mongodb_count      = 3
}

module "mongo_42_rs_0" {
  source        = "./modules/ec2"
  count         = local.mongodb_count
  server_name   = "${local.mongo_cluster_name}-rs-0-${count.index}"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/mongo_42.yml", {
    pmm_password        = random_password.pmm_admin_pass.result,
    name                = "${local.mongo_cluster_name}-rs-0-${count.index}",
    fqdn                = "${local.mongo_cluster_name}-rs-0-${count.index}.${aws_route53_zone.demo_local.name}",
    pmm_server_endpoint = local.pmm_server_endpoint,
  })
}

module "mongo_42_rs_0_disk" {
  source      = "./modules/ebs"
  count       = local.count
  disk_name   = "${local.mongo_cluster_name}-0-${count.index}"
  disk_size   = "64"
  instance_id = module.mongo_42_rs_0[count.index].instance_id
}


module "mongo_42_rs_1" {
  source        = "./modules/ec2"
  count         = local.mongodb_count
  server_name   = "${local.mongo_cluster_name}-rs-1-${count.index}"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/mongo_42.yml", {
    pmm_password        = random_password.pmm_admin_pass.result,
    name                = "${local.mongo_cluster_name}-rs-1-${count.index}",
    fqdn                = "${local.mongo_cluster_name}-rs-1-${count.index}.${aws_route53_zone.demo_local.name}",
    pmm_server_endpoint = local.pmm_server_endpoint,
  })
}

module "mongo_42_rs_1_disk" {
  source      = "./modules/ebs"
  count       = local.count
  disk_name   = "${local.mongo_cluster_name}-1-${count.index}"
  disk_size   = "64"
  instance_id = module.mongo_42_rs_1[count.index].instance_id
}

module "mongo_42_rs_2" {
  source        = "./modules/ec2"
  count         = local.mongodb_count
  server_name   = "${local.mongo_cluster_name}-rs-2-${count.index}"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/mongo_42.yml", {
    pmm_password        = random_password.pmm_admin_pass.result,
    name                = "${local.mongo_cluster_name}-rs-2-${count.index}",
    fqdn                = "${local.mongo_cluster_name}-rs-2-${count.index}.${aws_route53_zone.demo_local.name}",
    pmm_server_endpoint = local.pmm_server_endpoint,
  })
}

module "mongo_42_rs_2_disk" {
  source      = "./modules/ebs"
  count       = local.count
  disk_name   = "${local.mongo_cluster_name}-2-${count.index}"
  disk_size   = "64"
  instance_id = module.mongo_42_rs_2[count.index].instance_id
}
