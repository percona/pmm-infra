resource "aws_vpc" "pmmdemo" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = local.environment_name,
  }
  enable_dns_hostnames = true
}

resource "aws_route_table" "ig_pmmdemo" {
  vpc_id = aws_vpc.pmmdemo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pmmdemo.id
  }

  tags = {
    "Name" = local.environment_name,
  }
}

resource "aws_route_table_association" "pmmdemo" {
  subnet_id      = aws_subnet.pmmdemo_public.id
  route_table_id = aws_route_table.ig_pmmdemo.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "pmmdemo_public" {
  vpc_id                  = aws_vpc.pmmdemo.id
  availability_zone       = "us-east-1f"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    "Name" = local.environment_name,
  }
}

resource "aws_subnet" "pmmdemo_private" {
  vpc_id                  = aws_vpc.pmmdemo.id
  availability_zone       = "us-east-1f"
  cidr_block              = "10.0.2.0/24"

  tags = {
    "Name" = local.environment_name,
  }
}


resource "aws_internet_gateway" "pmmdemo" {
  vpc_id = aws_vpc.pmmdemo.id

  tags = {
    "Name" = local.environment_name,
  }
}

resource "aws_default_security_group" "pmmdemo" {
  vpc_id = aws_vpc.pmmdemo.id

  tags = {
    "Name" = "pmmdemo default security group",
  }
}

resource "aws_security_group_rule" "allow_private_network" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [aws_vpc.pmmdemo.cidr_block]
  security_group_id = aws_default_security_group.pmmdemo.id
}

resource "aws_security_group_rule" "allow_external_connections" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_default_security_group.pmmdemo.id
}


resource "aws_eip" "external_ip" {
  vpc = true
}

resource "aws_nat_gateway" "external_nat_gateway" {
  allocation_id = aws_eip.external_ip.id
  subnet_id     = aws_subnet.pmmdemo_public.id

  tags = {
    "Name" = local.environment_name,
  }

  depends_on = [aws_internet_gateway.pmmdemo]
}

resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.pmmdemo.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.external_nat_gateway.id
  }

  tags = {
    "Name" = local.environment_name,
  }
}

resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  subnet_id      = aws_subnet.pmmdemo_private.id
  route_table_id = aws_route_table.nat_route_table.id
}


resource "aws_route53_zone" "demo_local" {
  name = "${local.environment_name}.local"

  vpc {
    vpc_id = aws_vpc.pmmdemo.id
  }
}
