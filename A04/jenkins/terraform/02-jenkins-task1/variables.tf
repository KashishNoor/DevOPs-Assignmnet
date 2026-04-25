variable "aws_region" {
  description = "AWS region for Jenkins Task 1"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project prefix"
  type        = string
  default     = "kashish"
}

variable "my_ip_cidr" {
  description = "Student public IP in CIDR format, e.g. 1.2.3.4/32"
  type        = string
}

variable "controller_instance_type" {
  description = "Jenkins controller instance type"
  type        = string
  default     = "t3.small"
}

variable "agent_instance_type" {
  description = "Jenkins agent instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "kashish-jenkins-key"
}