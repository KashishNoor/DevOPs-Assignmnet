resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = var.key_name
  public_key = tls_private_key.jenkins_key.public_key_openssh

  tags = {
    Name    = var.key_name
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}

resource "local_sensitive_file" "jenkins_private_key" {
  filename        = "${path.module}/kashish-jenkins-key.pem"
  content         = tls_private_key.jenkins_key.private_key_pem
  file_permission = "0400"
}