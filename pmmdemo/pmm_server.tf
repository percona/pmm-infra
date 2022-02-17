locals {
  pmm_server_name = "pmm-server"
}

module "pmm_server" {
  source        = "./modules/ec2"
  server_name   = local.pmm_server_name
  instance_type = "m5.xlarge"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/pmm_server.yml",
    {
      pmm_admin_pass = random_password.pmm_admin_pass.result,
      name           = local.pmm_server_name,
      fqdn           = "${local.pmm_server_name}.${aws_route53_zone.demo_local.name}",

    }
  )
}

module "pmm_server_disk" {
  source      = "./modules/ebs"
  disk_name   = local.pmm_server_name
  disk_size   = "256"
  instance_id = module.pmm_server.instance_id
}

resource "random_password" "pmm_admin_pass" {
  length  = 20
  special = true
}
