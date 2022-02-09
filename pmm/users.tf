# TODO we need to use roles instead users
resource "aws_iam_user" "nikita" {
  name = "nikita.beletskii-cli"
}

resource "aws_iam_access_key" "nikita" {
  user = aws_iam_user.nikita.name
}

resource "aws_iam_user" "atymchuk" {
  name = "alex.tymchuk-cli"
}

resource "aws_iam_access_key" "atymchuk" {
  user = aws_iam_user.atymchuk.name
}

resource "aws_iam_policy_attachment" "administrator_access" {
  name       = "nikita.beletskii"
  users      = [aws_iam_user.nikita.name, aws_iam_user.atymchuk.name]
  roles      = ["sso-aws-pmm-admin"]
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

data "aws_iam_policy" "administrator_access" {
  name = "AdministratorAccess"
}
