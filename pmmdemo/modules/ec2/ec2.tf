resource "aws_instance" "ec2" {
  instance_type               = var.instance_type
  ami                         = var.ami_id
  associate_public_ip_address = var.has_public_ip
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_groups
  key_name                    = data.aws_key_pair.pmm-demo.key_name
  iam_instance_profile        = var.iam_role_name

  # EC2 caps user-data at 16 KB decoded. Several of these cloud-init templates
  # render close to that -- pmm_server.yml exceeds it outright -- so compress.
  # cloud-init detects the gzip magic bytes and inflates before parsing.
  user_data_base64 = base64gzip(var.user_data)

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
    //
    // instance_type follows the same reasoning: hosts get resized by hand in
    // response to load, and Terraform should not undo that on an unrelated
    // apply. Consequence: editing instance_type here has no effect on a running
    // instance -- resize it directly, or remove it from this list first.
    ignore_changes = [ami, instance_type]

    // Fail at plan time rather than getting an opaque rejection from the EC2
    // API. 21848 base64 characters is 16 KB once decoded, which is the cap.
    // base64decode() is not usable for this check because gzip output is not
    // valid UTF-8.
    precondition {
      condition     = length(base64gzip(var.user_data)) <= 21848
      error_message = "Rendered user-data for ${var.server_name} exceeds the 16 KB EC2 limit even after gzip compression. Move content out of cloud-init: fetch it at boot, or bake it into the AMI."
    }
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