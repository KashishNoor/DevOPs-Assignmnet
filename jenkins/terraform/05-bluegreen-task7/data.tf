data "aws_caller_identity" "current" {}

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

data "aws_ecr_repository" "app" {
  name = var.ecr_repository_name
}

data "aws_iam_role" "jenkins_agent_role" {
  name = "${var.project_name}-jenkins-agent-role"
}