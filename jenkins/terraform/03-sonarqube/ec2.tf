resource "aws_instance" "sonarqube" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.sonarqube_instance_type
  subnet_id                   = data.terraform_remote_state.base.outputs.public_subnet_ids[0]
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sonarqube_sg.id]
  user_data                   = file("${path.module}/sonarqube-user-data.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "${var.project_name}-sonarqube"
    Role    = "sonarqube"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}
