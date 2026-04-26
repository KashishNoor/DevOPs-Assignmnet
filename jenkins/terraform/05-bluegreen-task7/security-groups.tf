resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-bluegreen-alb-sg"
  description = "ALB security group for blue-green deployment"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description = "Production HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "Smoke test listener from anywhere for Jenkins demo"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bluegreen-alb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-bluegreen-app-sg"
  description = "App instance security group"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    description     = "App traffic from ALB only"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH from my IP for debugging only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Allow outbound for ECR pull"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bluegreen-app-sg"
  }
}