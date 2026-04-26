data "aws_iam_role" "jenkins_agent_role" {
  name = var.jenkins_agent_role_name
}

resource "aws_iam_role_policy" "jenkins_agent_ecr_push" {
  name = "${var.project_name}-jenkins-agent-ecr-push-policy"
  role = data.aws_iam_role.jenkins_agent_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEcrLogin"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPushPullToAttendanceRepository"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = aws_ecr_repository.attendance_app.arn
      }
    ]
  })
}