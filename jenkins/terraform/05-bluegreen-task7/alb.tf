resource "aws_lb" "bluegreen" {
  name               = "${var.project_name}-bluegreen-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.base.outputs.public_subnet_ids

  tags = {
    Name = "${var.project_name}-bluegreen-alb"
  }
}

resource "aws_lb_target_group" "blue" {
  name        = "${var.project_name}-tg-blue"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name  = "${var.project_name}-tg-blue"
    Color = "blue"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.project_name}-tg-green"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name  = "${var.project_name}-tg-green"
    Color = "green"
  }
}

resource "aws_lb_listener" "production" {
  load_balancer_arn = aws_lb.bluegreen.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = {
    Name = "${var.project_name}-prod-listener"
  }
}

resource "aws_lb_listener" "smoke_test" {
  load_balancer_arn = aws_lb.bluegreen.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = {
    Name = "${var.project_name}-smoke-listener"
  }
}