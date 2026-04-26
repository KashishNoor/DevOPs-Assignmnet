variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "project_name" {
  type    = string
  default = "kashish"
}

variable "my_ip_cidr" {
  type        = string
  description = "Student public IP CIDR"
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "kashish-jenkins-key"
}

variable "ecr_repository_name" {
  type    = string
  default = "attendance-app"
}

variable "initial_image_tag" {
  type        = string
  description = "Existing ECR image tag used for initial blue/green instances"
  default     = "manual"
}

variable "deployment_log_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket for deployment log JSONL"
}