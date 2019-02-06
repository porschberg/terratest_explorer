# Before us this template, generate SSH-Key-Files with "ssh-keygen" with the name "crispy"!

resource "tls_private_key" "terratest_key" {
  algorithm   = "RSA"
}

resource "aws_ssm_parameter" "ssh_private" {
  name = "/terratest_explorer/${terraform.workspace}/ssh_key_pem"
  type = "SecureString"
  value = "${tls_private_key.terratest_key.private_key_pem}"
  description = "The PRIVATE ssh-key created by terraform. This key can be downloaded via 'get_ssh_key.sh' and used to login."
}

resource "aws_ssm_parameter" "ssh_public" {
  name = "/terratest_explorer/${terraform.workspace}/ssh_key_pub"
  type = "String"
  value = "${tls_private_key.terratest_key.public_key_openssh}"
  description = "The PUBLIC ssh-key created by terraform. This key can be downloaded via 'get_ssh_key.sh' and used to login."
}

output "terratest_explorer_private_key" {
  value = "${tls_private_key.terratest_key.private_key_pem}"
}

output "terratest_explorer_public_key" {
  value = "${tls_private_key.terratest_key.public_key_openssh}"
}
