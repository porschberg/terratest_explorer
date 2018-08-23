resource "tls_private_key" "terratest_key" {
  algorithm   = "RSA"
}

resource "aws_ssm_parameter" "terratest_key_pem_ssm" {
  name = "/terratest_explorer/${terraform.workspace}/terratest_key_pem"
  type = "SecureString"
  value = "${tls_private_key.terratest_key.private_key_pem}"
}

resource "aws_ssm_parameter" "terratest_key_pub_openssh_ssm" {
  name = "/terratest_explorer/${terraform.workspace}/terratest_key_pub_openssh"
  type = "String"
  value = "${tls_private_key.terratest_key.public_key_openssh}"
}

//output "terratest_explorer_private_key" {
//  value = "${tls_private_key.terratest_key.private_key_pem}"
//}
//
//output "terratest_explorer_public_key" {
//  value = "${tls_private_key.terratest_key.public_key_openssh}"
//}

