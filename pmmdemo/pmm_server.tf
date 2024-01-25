locals {
  pmm_server_name = "pmm-server"
}

module "pmm_server" {
  source        = "./modules/ec2"
  server_name   = local.pmm_server_name
  instance_type = "m5a.xlarge"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

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
  length  = 8
  special = false
  lower   = false
  numeric = false
}

data "aws_iam_user" "rds_user" {
  user_name = "pmm-demo-rds-user"
}

data "aws_iam_policy" "pmmdemo-rds-policy" {
  name = "pmm-demo-rds-policy"
}

data "aws_iam_role" "pmmdemo_dlm_lifecycle" {
  name = "pmmdemo-dlm-lifecycle"
}

data "aws_secretsmanager_secret" "sso_creds_mgr" {
  name = "pmm-sso-oauth-creds"
}

data "aws_secretsmanager_secret_version" "sso_creds" {
  secret_id = data.aws_secretsmanager_secret.sso_creds_mgr.id
}

resource "aws_iam_access_key" "rds_user_access_key" {
  user = data.aws_iam_user.rds_user.user_name
}

resource "aws_iam_policy_attachment" "rds_policy" {
  name       = "rds_policy"
  users      = [data.aws_iam_user.rds_user.user_name]
  policy_arn = data.aws_iam_policy.pmmdemo-rds-policy.arn
}

resource "aws_iam_role_policy" "pmmdemo_dlm_lifecycle" {
  name = "pmmdemo-dlm-lifecycle"
  role = data.aws_iam_role.pmmdemo_dlm_lifecycle.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DeleteSnapshot",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "pmmdemo" {
  description        = "PMM Demo DLM lifecycle policy"
  execution_role_arn = data.aws_iam_role.pmmdemo_dlm_lifecycle.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "PMM Demo everyday snapshot"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      "Name" = "pmmdemo-${local.pmm_server_name}"
    }
  }
}
