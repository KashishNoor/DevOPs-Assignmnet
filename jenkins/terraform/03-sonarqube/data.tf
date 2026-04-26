data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_security_group" "jenkins_agent_sg" {
  filter {
    name   = "group-name"
    values = ["${var.project_name}-jenkins-agent-sg"]
  }

  vpc_id = data.terraform_remote_state.base.outputs.vpc_id
}

data "aws_security_group" "jenkins_controller_sg" {
  filter {
    name   = "group-name"
    values = ["${var.project_name}-jenkins-controller-sg"]
  }

  vpc_id = data.terraform_remote_state.base.outputs.vpc_id
}

data "aws_instance" "jenkins_controller" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-jenkins-controller"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}