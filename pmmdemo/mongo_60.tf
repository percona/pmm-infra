locals {
  mongo_cluster_name = "mongo-60"
  mongodb_count      = 3
}

module "mongo_cluster_pmmdemo" {
  source       = "./modules/mongo_cluster"
  subnet_id    = aws_subnet.pmmdemo_private.id
  route53_id   = aws_route53_zone.demo_local.id
  route53_name = aws_route53_zone.demo_local.name
  security_groups = [
    aws_security_group.default_access.id
  ]
  instance_type        = "t3.medium"
  config_instance_type = "t3.small"
  mongos_instance_type = "t3.small"

  pmm_server_endpoint   = local.pmm_server_endpoint
  pmm_password          = random_password.pmm_admin_pass.result
  mongodb_ycsb_password = random_password.mongodb_ycsb_password.result
}
