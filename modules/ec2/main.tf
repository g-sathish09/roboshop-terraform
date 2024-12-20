resource "aws_security_group" "sg" {
  name        = "${var.component_name}-${var.env}-sg"
  description = "Inbound allow for ${var.component_name}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "${var.component_name}-${var.env}"
  }
  root_block_device {
    volume_size = var.volume_size
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

}

resource "null_resource" "ansible-pull" {

  triggers = {
    instance_id = aws_instance.instance.id
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = data.vault_generic_secret.ssh.data["username"]
      password = data.vault_generic_secret.ssh.data["password"]
      host     = aws_instance.instance.private_ip
    }
    inline = [
      "sudo dnf install -y epel-release",
      "sudo dnf install -y ansible",
      "ansible-pull -i localhost, -U https://github.com/gunasekaransathish/roboshop-ansible roboshop.yml -e env=${var.env} -e component=${var.component_name} -e vault_token=${var.vault_token}"
    ]

  }
}

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "${var.component_name}-${var.env}.${var.domain_name}"
  type    = "A"
  ttl     = "30"
  records = [aws_instance.instance.private_ip]
}