locals {
  pmm_server_name = "pmm-server"
}

module "pmm_server" {
  source        = "./modules/ec2"
  server_name   = local.pmm_server_name
  instance_type = "m5.xlarge"
  subnet_id     = aws_subnet.pmmdemo_private.id
  route53_id    = aws_route53_zone.demo_local.id

  security_groups = [
    aws_security_group.default_access.id
  ]
  user_data = templatefile("provision_scripts/pmm_server.yml",
    {
      pmm_admin_pass             = random_password.pmm_admin_pass.result
      name                       = local.pmm_server_name
      fqdn                       = "${local.pmm_server_name}.${aws_route53_zone.demo_local.name}"
      full_domain                = var.pmm_domain
      google_analytics_id        = var.google_analytics_id
      oauth_enable               = var.oauth_enable
      oauth_client_id            = var.oauth_client_id
      oauth_secret               = var.oauth_secret
      oauth_url                  = var.oauth_url
      oauth_token_url            = var.oauth_token_url
      oauth_api_url              = var.oauth_api_url
      oauth_scopes               = var.oauth_scopes
      oauth_role_attribute_path  = var.oauth_role_attribute_path
      oauth_signout_redirect_url = var.oauth_signout_redirect_url
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
  length  = 20
  special = false
}

resource "aws_iam_user" "rds_user" {
  name = "pmm-demo-rds-user"
}


resource "aws_iam_policy" "pmmdemo-rds-policy" {
  name        = "pmm-demo-rds-policy"
  path        = "/"
  description = "Policy for rds database discovery"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1508404837000",
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ],
        "Resource" : ["*"]
      },
      {
        "Sid" : "Stmt1508410723001",
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource" : ["arn:aws:logs:*:*:log-group:RDSOSMetrics:*"]
      }
  ] })
}

resource "aws_iam_access_key" "rds_user_access_key" {
  user = aws_iam_user.rds_user.name
}

resource "aws_iam_policy_attachment" "rds_policy" {
  name       = "rds_policy"
  users      = [aws_iam_user.rds_user.name]
  policy_arn = aws_iam_policy.pmmdemo-rds-policy.arn
}

resource "aws_iam_role" "pmmdemo_dlm_lifecycle" {
  name = "pmmdemo-dlm-lifecycle"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "pmmdemo_dlm_lifecycle" {
  name = "pmmdemo-dlm-lifecycle"
  role = aws_iam_role.pmmdemo_dlm_lifecycle.id

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
  execution_role_arn = aws_iam_role.pmmdemo_dlm_lifecycle.arn
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
