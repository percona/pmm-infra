# TODO we need to use roles instead users
resource "aws_iam_user" "nbeletskii" {
  name = "nikita.beletskii-cli"
}

resource "aws_iam_access_key" "nbeletskii" {
  user = aws_iam_user.nbeletskii.name
}

resource "aws_iam_user" "atymchuk" {
  name = "alex.tymchuk-cli"
}

resource "aws_iam_access_key" "atymchuk" {
  user = aws_iam_user.atymchuk.name
}

resource "aws_iam_policy_attachment" "administrator_access" {
  name       = "nikita.beletskii"
  users      = [aws_iam_user.nbeletskii.name, aws_iam_user.atymchuk.name]
  roles      = ["sso-aws-pmm-admin"]
  policy_arn = aws_iam_policy.pmm_cli.arn

  lifecycle {
     prevent_destroy = true
  }
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
