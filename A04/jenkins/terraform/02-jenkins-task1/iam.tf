resource "aws_iam_role" "jenkins_agent_role" {
  name = "${var.project_name}-jenkins-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-jenkins-agent-role"
    Project = "devops-assignment-4"
    Owner   = "kashish"
  }
}

resource "aws_iam_role_policy_attachment" "agent_ecr_power_user" {
  role       = aws_iam_role.jenkins_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "agent_ssm_core" {
  role       = aws_iam_role.jenkins_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_agent_profile" {
  name = "${var.project_name}-jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent_role.name
}