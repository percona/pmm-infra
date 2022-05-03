resource "aws_ebs_volume" "data_disk" {
  availability_zone = "us-west-1b"
  size = var.disk_size
  type = var.disk_type

 lifecycle {
    prevent_destroy = false
  }

  tags = {
    "Name" = "pmmdemo-${var.disk_name}",
  }
}

resource "aws_volume_attachment" "pmm_server_data_disk_attach" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.data_disk.id
  instance_id = var.instance_id
}
