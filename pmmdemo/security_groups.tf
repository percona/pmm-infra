resource "aws_security_group" "bastion" {
  name        = "pmmdemo_ssh_bastion"
  description = "Allow outside SSH connections (Bastion)"
  vpc_id      = aws_vpc.pmmdemo.id

  tags = {
    "Name" = "pmmdemo-bastion",
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# we use separate rules here because it'll be easier to modify
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# Intra-VPC access between demo hosts. Egress is deliberately NOT granted here:
# security group rules are a union of allows, so a blanket 0.0.0.0/0 egress on a
# shared group makes it impossible to constrain any single host. Egress is
# granted per role by the two groups below.
resource "aws_security_group" "default_access" {
  vpc_id = aws_vpc.pmmdemo.id
  name   = "pmmdemo-default-access-sg"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

# Unrestricted egress, for the workload hosts that install packages, pull
# container images and generate load against external endpoints.
resource "aws_security_group" "general_egress" {
  vpc_id = aws_vpc.pmmdemo.id
  name   = "pmmdemo-general-egress-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Narrower egress for pmm-server, which reaches the widest set of internal
# systems and therefore makes the most valuable pivot point.
#
# Scope of the protection, stated honestly: restricting outbound to 80/443 plus
# the VPC blocks non-HTTP pivots -- mongodb() on 27017, remote() on 9000, SMTP,
# arbitrary TCP. It does NOT block HTTP-based request forgery such as
# ClickHouse's url(), because the host legitimately bootstraps over HTTPS from
# package repositories and container registries. Closing that would require
# pre-baked AMIs or an egress proxy. The controls that actually address url()
# are the least-privilege datasource identity and IMDSv2.
resource "aws_security_group" "pmm_server_egress" {
  vpc_id = aws_vpc.pmmdemo.id
  name   = "pmmdemo-pmm-server-egress-sg"

  # Monitored databases and the interface endpoints below.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.pmmdemo.cidr_block]
  }

  # Package repositories, container registries, Percona SSO.
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aurora_engine" {
  name = "pmmdemo-aurora-engine-sg"

  vpc_id = aws_vpc.pmmdemo.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${module.pmm_server.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
