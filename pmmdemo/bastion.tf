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
    name           = local.bastion_name,
    project_name   = local.environment_name,
    domain         = var.pmm_domain,
    email          = var.owner_email,
    pmm_admin_pass = random_password.pmm_admin_pass.result,
    fqdn           = "${local.bastion_name}.${aws_route53_zone.demo_local.name}",
  })
}

data "aws_route53_zone" "pmmdemo" {
  name         = "perconatest.com."
  private_zone = false
}

resource "aws_route53_record" "pmmdemo_hostname" {
  zone_id = data.aws_route53_zone.pmmdemo.id
  name    = var.pmm_domain
  type    = "A"
  ttl     = "300"
  records = [module.bastion.public_ip]
}

module "bastion_disk" {
  source      = "./modules/ebs"
  disk_name   = "bastion"
  disk_size   = "8"
  instance_id = module.bastion.instance_id
}

output "public_ip" {
  value = module.bastion.public_ip
}
