# data "aws_ami" "ami" {
#   most_recent = true
#   name_regex  = "RHEL-9-DevOps-Practice"
#   owners      = ["973714476881"]
# }

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "rhel-golden-image"
  owners      = ["self"]
}


data "vault_generic_secret" "ssh" {
  path = "infra-secrets/ssh"
}