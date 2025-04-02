locals {
  pmm_server_name = "pmm-server"
}

module "pmm_server" {
  source          = "./modules/ec2"
  server_name     = local.pmm_server_name
  instance_type   = "m5a.xlarge"
  subnet_id       = aws_subnet.pmmdemo_private.id
  route53_id      = aws_route53_zone.demo_local.id
  iam_role_name   = aws_iam_instance_profile.pmmdemo_ec2_rds_profile.name
  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/pmm_server.yml",
    {
      environment_name           = local.environment_name
      fqdn                       = "${local.pmm_server_name}.${aws_route53_zone.demo_local.name}"
      full_domain                = var.pmm_domain
      google_analytics_id        = var.google_analytics_id
      local_domain               = "${local.environment_name}.local"
      name                       = local.pmm_server_name
      oauth_api_url              = var.oauth_api_url
      oauth_client_id            = jsondecode(data.aws_secretsmanager_secret_version.sso_creds.secret_string)["OAUTH_CLIENTID"]
      oauth_enable               = var.oauth_enable
      oauth_role_attribute_path  = var.oauth_role_attribute_path
      oauth_scopes               = var.oauth_scopes
      oauth_secret               = jsondecode(data.aws_secretsmanager_secret_version.sso_creds.secret_string)["OAUTH_CLIENTSECRET"]
      oauth_signout_redirect_url = var.oauth_signout_redirect_url
      oauth_token_url            = var.oauth_token_url
      oauth_url                  = var.oauth_url
      pmm_admin_pass             = random_password.pmm_admin_pass.result
      pmm_server_endpoint        = local.pmm_server_endpoint
      scripts_path               = local.scripts_path
      rds_mysql_username         = local.rds_mysql_username
      rds_mysql_password         = random_password.rds_mysql_80_password.result
    }
  )
}

module "pmm_server_disk" {
  source      = "./modules/ebs"
  disk_name   = local.pmm_server_name
  disk_size   = 256
  instance_id = module.pmm_server.instance_id
}

resource "random_password" "pmm_admin_pass" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 4
  special     = false
}

data "aws_iam_user" "rds_user" {
  user_name = "pmm-demo-rds-user"
}

# Create the policy allowing RDS, and Cloudwatch access for PMM
resource "aws_iam_policy" "pmmdemo_rds_policy" {
  name        = "pmmdemo-rds-policy"
  description = "Policy to allow PMM to discover, and monitor RDS instances"
  policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "Stmt1508404837000",
    "Effect": "Allow",
    "Action": [
      "rds:DescribeDBInstances",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "rds:DescribeDBClusters"
    ],
    "Resource": ["*"]
  },
  {
	"Sid": "Stmt1508410723001",
	"Effect": "Allow",
	"Action": [
	  "logs:DescribeLogStreams",
	  "logs:GetLogEvents",
	  "logs:FilterLogEvents"
	],
	"Resource": [
	  "arn:aws:logs:*:*:log-group:RDSOSMetrics:*"
	]
  }]
}
EOT
}

# Create a role which will have the above policy attached
resource "aws_iam_role" "pmmdemo_rds_role" {
  name               = "pmmdemo-rds-role"
  description        = "Role used by PMM EC2 to discover RDS"
  assume_role_policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [{
	  "Effect": "Allow",
	  "Principal": {
		"Service": "ec2.amazonaws.com"
	  },
	  "Action": "sts:AssumeRole"
	}]
  })
}

# Attach the PMMDemo RDS policy to the PMMDemo RDS role
resource "aws_iam_role_policy_attachment" "pmmdemo_rds_role_attachement" {
  role       = aws_iam_role.pmmdemo_rds_role.name
  policy_arn = aws_iam_policy.pmmdemo_rds_policy.arn
}

# Create an EC2 instance profile, and attach the PMMDemo RDS role.
# This allows the PMMDemo EC2 instance to use the IAM role
resource "aws_iam_instance_profile" "pmmdemo_ec2_rds_profile" {
  name = "pmmdemo-ec2-rds-profile"
  role = aws_iam_role.pmmdemo_rds_role.name
}

data "aws_secretsmanager_secret" "sso_creds_mgr" {
  name = "pmm-sso-oauth-creds"
}

data "aws_secretsmanager_secret_version" "sso_creds" {
  secret_id = data.aws_secretsmanager_secret.sso_creds_mgr.id
}

resource "aws_iam_access_key" "rds_user_access_key" {
  count = var.DBAAS > 0 ? 1 : 0
  user = data.aws_iam_user.rds_user.user_name
}

# resource "aws_iam_policy_attachment" "rds_policy" {
#   name       = "rds_policy"
#   users      = [data.aws_iam_user.rds_user.user_name]
#   policy_arn = aws_iam_policy.pmmdemo-rds-policy.arn
# }

