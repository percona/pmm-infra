locals {
  bastion_name = "bastion"
}

module "bastion" {
  source        = "./modules/ec2"
  server_name   = local.bastion_name
  instance_type = "m5.large"
  has_public_ip = true
  subnet_id     = aws_subnet.pmmdemo_public.id
  route53_id    = aws_route53_zone.demo_local.id
  security_groups = [
    aws_security_group.default_access.id,
    aws_security_group.bastion.id
  ]
  user_data = templatefile("provision_scripts/bastion.yml", {
    name = local.bastion_name,
    domain = var.pmm_domain,
    email = var.owner_email
  })
}

data "aws_route53_zone" "pmmdemo" {
  name         = "percona.net."
  private_zone = false
}

resource "aws_route53_record" "pmmdemo_hostname" {
  zone_id = data.aws_route53_zone.pmmdemo.id
  name    = "pmmdemo.dev.percona.net"
  type    = "A"
  ttl     = "300"
  records = [module.bastion.public_ip]
}


output "public_ip" {
  value = module.bastion.public_ip
}
