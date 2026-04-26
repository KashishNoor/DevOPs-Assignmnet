resource "aws_security_group" "sonarqube_sg" {
  name        = "${var.project_name}-sonarqube-sg"
  description = "Security group for SonarQube server"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description = "SonarQube UI from my IP only"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description     = "SonarQube access from Jenkins agent"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [data.aws_security_group.jenkins_agent_sg.id]
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
    Name    = "${var.project_name}-sonarqube-sg"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}

resource "aws_security_group_rule" "allow_sonarqube_webhook_to_jenkins" {
  type                     = "ingress"
  description              = "Allow SonarQube webhook to Jenkins controller"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.jenkins_controller_sg.id
  source_security_group_id = aws_security_group.sonarqube_sg.id
}