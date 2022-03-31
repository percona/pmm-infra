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
      pmm_admin_pass      = random_password.pmm_admin_pass.result
      name                = local.pmm_server_name
      fqdn                = "${local.pmm_server_name}.${aws_route53_zone.demo_local.name}"
      full_domain         = aws_route53_zone.demo_local.name
      google_analytics_id = var.google_analytics_id
      oauth_enable        = var.oauth_enable
      oauth_client_id     = var.oauth_client_id
      oauth_secret        = var.oauth_secret
      oauth_url           = var.oauth_url
      oauth_token_url     = var.oauth_token_url
      oauth_api_url       = var.oauth_api_url
      oauth_scopes        = var.oauth_scopes
    }
  )
}

module "pmm_server_disk" {
  source      = "./modules/ebs"
  disk_name   = local.pmm_server_name
  disk_size   = "256"
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
    "Statement" : [{ "Sid" : "Stmt1508404837000",
      "Effect" : "Allow",
      "Action" : ["rds:DescribeDBInstances",
        "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"],
      "Resource" : ["*"] },
      { "Sid" : "Stmt1508410723001",
        "Effect" : "Allow",
        "Action" : ["logs:DescribeLogStreams",
          "logs:GetLogEvents",
        "logs:FilterLogEvents"],
      "Resource" : ["arn:aws:logs:*:*:log-group:RDSOSMetrics:*"] }
  ] })
}

resource "aws_iam_access_key" "rds_user_access_key" {
  user = aws_iam_user.rds_user.name
}
