resource "aws_instance" "jenkins_controller" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.controller_instance_type
  subnet_id                   = data.terraform_remote_state.base.outputs.public_subnet_ids[0]
  key_name                    = aws_key_pair.jenkins_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_controller_sg.id]
  user_data                   = file("${path.module}/controller-user-data.sh")

  root_block_device {
    volume_size = 25
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "${var.project_name}-jenkins-controller"
    Role    = "jenkins-controller"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.agent_instance_type
  subnet_id                   = data.terraform_remote_state.base.outputs.private_subnet_ids[0]
  key_name                    = aws_key_pair.jenkins_key.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.jenkins_agent_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_agent_profile.name
  user_data                   = file("${path.module}/agent-user-data.sh")

  root_block_device {
    volume_size = 25
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "${var.project_name}-jenkins-agent"
    Role    = "jenkins-agent"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}