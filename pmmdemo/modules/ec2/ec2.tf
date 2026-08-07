resource "aws_instance" "ec2" {
  instance_type               = var.instance_type
  ami                         = var.ami_id
  associate_public_ip_address = var.has_public_ip
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_groups
  user_data                   = var.user_data
  key_name                    = data.aws_key_pair.pmm-demo.key_name
  iam_instance_profile        = var.iam_role_name

  # Require IMDSv2 (session-token) for instance metadata. IMDSv1 answers any
  # plain GET, which makes any request-forgery primitive on the host equivalent
  # to a read of the instance role credentials and of user-data.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.imds_http_tokens
    http_put_response_hop_limit = var.imds_hop_limit
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_type = var.root_disk_type
    volume_size = var.root_disk_size
    tags = {
      "Name"      = "${local.environment_name}-${var.server_name}",
      "terraform" = "yes",
    }
  }

  tags = {
    "Name" = "${local.environment_name}-${var.server_name}",
  }

  lifecycle {
	// We want to have latest AMI on recreating but don't want to recreate if we have new AMI version
	ignore_changes = [ami]
  }

}

resource "aws_route53_record" "hostname" {
  zone_id = var.route53_id
  name    = var.server_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.ec2.private_ip]
}

locals {
  environment_name = terraform.workspace
}