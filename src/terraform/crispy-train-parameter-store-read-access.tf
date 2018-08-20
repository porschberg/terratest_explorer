resource "aws_iam_policy" "readonly_crispy_parameter_store" {
  name        = "crispy_ro_ssm_policy-${terraform.workspace}"
  path        = "/"
  description = "Read only access to parameter-store for crispy-train"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt4637463564248",
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:eu-central-1:512241874122:key/8432bf87-5e63-468b-b8fe-004cc9acf6da"
    },
    {
      "Sid": "Stmt1517399021096",
      "Action": [
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:eu-central-1:512241874122:parameter/crispytrain*"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "crispy_ro_profile" {
  name = "crispy_ro_profile-${terraform.workspace}"
  role = "${aws_iam_role.crispy_ec2_role.name}"
}

resource "aws_iam_role" "crispy_ec2_role" {
  name = "crispy_ec2_role-${terraform.workspace}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "crispy_ro_role_attach" {
    role       = "${aws_iam_role.crispy_ec2_role.name}"
    policy_arn = "${aws_iam_policy.readonly_crispy_parameter_store.arn}"
}

