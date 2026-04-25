variable "aws_region" {
  description = "AWS region for Assignment 4"
  type        = string
  default     = "eu-north-1"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "kashish-terraform-state-locking"
}