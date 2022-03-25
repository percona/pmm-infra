locals {
  sysbench_name = "sysbench"
}

module "sysbench" {
  source        = "./modules/ec2"
  server_name   = local.sysbench_name
  instance_type = "t3.small"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
  ]
  user_data = templatefile("provision_scripts/sysbench.yml", {
    name                       = local.sysbench_name,
    domain                     = var.pmm_domain,
    pmm_admin_password         = random_password.pmm_admin_pass.result
    pmm_server_endpoint        = local.pmm_server_endpoint
    fqdn                       = "${local.sysbench_name}.${aws_route53_zone.demo_local.name}",
    percona_server_80_password = random_password.mysql80_sysbench_password.result
  })
}
