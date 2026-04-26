locals {
  ecr_registry      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  initial_image_uri = "${data.aws_ecr_repository.app.repository_url}:${var.initial_image_tag}"
}

resource "aws_launch_template" "blue" {
  name_prefix   = "${var.project_name}-lt-blue-"
  image_id      = data.aws_ami.ubuntu_2204.id
  instance_type = var.app_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.tpl", {
    aws_region   = var.aws_region
    ecr_registry = local.ecr_registry
    image_uri    = local.initial_image_uri
    color        = "blue"
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name  = "${var.project_name}-blue-instance"
      Color = "blue"
    }
  }

  tags = {
    Name = "${var.project_name}-lt-blue"
  }
}

resource "aws_launch_template" "green" {
  name_prefix   = "${var.project_name}-lt-green-"
  image_id      = data.aws_ami.ubuntu_2204.id
  instance_type = var.app_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.tpl", {
    aws_region   = var.aws_region
    ecr_registry = local.ecr_registry
    image_uri    = local.initial_image_uri
    color        = "green"
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name  = "${var.project_name}-green-instance"
      Color = "green"
    }
  }

  tags = {
    Name = "${var.project_name}-lt-green"
  }
}

resource "aws_autoscaling_group" "blue" {
  name                = "${var.project_name}-asg-blue"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = data.terraform_remote_state.base.outputs.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.blue.arn]

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-blue"
    propagate_at_launch = true
  }

  tag {
    key                 = "Color"
    value               = "blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green" {
  name                = "${var.project_name}-asg-green"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = data.terraform_remote_state.base.outputs.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.green.arn]

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-green"
    propagate_at_launch = true
  }

  tag {
    key                 = "Color"
    value               = "green"
    propagate_at_launch = true
  }
}