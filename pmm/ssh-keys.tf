resource "aws_key_pair" "pmm-demo" {
  key_name   = "pmm-demo"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID7e+uJrVmh6fUWC4YbX/MB/2jBNxE9V6pql7SGT1I2m pmm-demo-user"
}

