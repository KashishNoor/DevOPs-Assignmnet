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

variable "my_ip_cidr" {
  description = "Your public IP in CIDR format"
  type        = string
}

variable "sonarqube_instance_type" {
  description = "SonarQube EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "kashish-jenkins-key"
}
