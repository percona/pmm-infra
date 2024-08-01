# These roles and policies should be created first as "global" resources
# which are then imported and used by everyone. They will not be destroyed
# when someone executed 'terraform destroy' from within the pmmdemo directory

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
          "rds:DescribeDBClusters",
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
