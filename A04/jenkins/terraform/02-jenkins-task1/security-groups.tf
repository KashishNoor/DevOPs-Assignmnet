resource "aws_security_group" "jenkins_controller_sg" {
  name        = "${var.project_name}-jenkins-controller-sg"
  description = "Security group for Jenkins controller"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description = "Jenkins UI from my IP only"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-jenkins-controller-sg"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}

resource "aws_security_group" "jenkins_agent_sg" {
  name        = "${var.project_name}-jenkins-agent-sg"
  description = "Security group for Jenkins private build agent"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description     = "SSH from Jenkins controller only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_controller_sg.id]
  }

  egress {
    description = "Allow all outbound traffic through NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-jenkins-agent-sg"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}