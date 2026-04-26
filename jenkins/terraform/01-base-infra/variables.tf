variable "aws_region" {
  description = "AWS region for Assignment 4"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project/name prefix"
  type        = string
  default     = "kashish"
}

variable "vpc_cidr" {
  description = "CIDR block for Assignment 3 base VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for public/private subnets"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}