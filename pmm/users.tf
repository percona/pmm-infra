# The pmmdemo-admin-group should be managed from UI, which allows to 
# give users permissions other than just those related to pmmdemo.
data "aws_iam_group" "pmmdemo_admin_group" {
  group_name = "pmmdemo-admin-group"
}

resource "aws_iam_group_policy_attachment" "admin_access" {
  group = data.aws_iam_group.pmmdemo_admin_group.group_name
  policy_arn = aws_iam_policy.pmm_cli.arn
}

resource "aws_iam_policy" "pmm_cli" {
  name        = "pmm_cli"
  path        = "/"
  description = "Temporary policy for cli users"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": "*",
          "Resource": "*"
        }
    ]
  })
}
