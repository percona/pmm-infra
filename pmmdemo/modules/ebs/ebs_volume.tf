resource "aws_ebs_volume" "data_disk" {
  availability_zone = "us-east-1f"
  size              = var.disk_size
  type              = var.disk_type

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "${local.environment_name}-${var.disk_name}",
  }
}

resource "aws_volume_attachment" "data_disk_attach" {
  device_name  = var.device_name
  volume_id    = aws_ebs_volume.data_disk.id
  instance_id  = var.instance_id
  force_detach = true
}

locals {
  environment_name = terraform.workspace
}