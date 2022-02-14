resource "aws_key_pair" "pmm-demo" {
  key_name   = "pmm-demo"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2R7C3bpt5n1rTI2dH+pZ4SW8lfLOlxutm4seSDDUdU pmm-demo-user"
}

