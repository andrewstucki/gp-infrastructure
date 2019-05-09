resource "aws_iam_user" "terraform" {
  name = "terraform"
}

resource "aws_iam_access_key" "terraform" {
  user = "${aws_iam_user.terraform.name}"
}

resource "aws_iam_user_policy" "terraform" {
  name = "terraform"
  user = "${aws_iam_user.terraform.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "*" ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
