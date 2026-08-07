# Interface endpoints for the AWS APIs pmm-managed calls during RDS discovery.
#
# Without these, that traffic leaves through the NAT gateway and the only way to
# permit it is a broad 0.0.0.0/0:443 egress rule -- which is also the rule an
# HTTP request-forgery primitive would use. With private DNS enabled,
# rds.<region>.amazonaws.com and monitoring.<region>.amazonaws.com resolve to
# addresses inside the VPC, so the AWS calls no longer depend on internet
# egress.
#
# This does not by itself let us drop the 0.0.0.0/0:443 rule from
# pmm_server_egress: the host still bootstraps from package repositories and
# container registries over HTTPS. Removing it needs pre-baked AMIs or an egress
# proxy, tracked separately.

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "rds" {
  vpc_id              = aws_vpc.pmmdemo.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.rds"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.pmmdemo_private.id]
  security_group_ids  = [aws_security_group.default_access.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${local.environment_name}-rds-endpoint",
  }
}

resource "aws_vpc_endpoint" "monitoring" {
  vpc_id              = aws_vpc.pmmdemo.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.pmmdemo_private.id]
  security_group_ids  = [aws_security_group.default_access.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${local.environment_name}-monitoring-endpoint",
  }
}
