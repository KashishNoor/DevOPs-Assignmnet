variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project prefix"
  type        = string
  default     = "kashish"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "attendance-app"
}

variable "jenkins_agent_role_name" {
  description = "IAM role attached to Jenkins agent EC2"
  type        = string
  default     = "kashish-jenkins-agent-role"
}