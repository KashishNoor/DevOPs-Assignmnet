output "ecr_repository_name" {
  value = aws_ecr_repository.attendance_app.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.attendance_app.repository_url
}

output "jenkins_agent_role_name" {
  value = data.aws_iam_role.jenkins_agent_role.name
}