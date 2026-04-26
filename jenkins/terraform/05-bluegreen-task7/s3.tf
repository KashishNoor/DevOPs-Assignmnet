resource "aws_s3_bucket" "deployment_logs" {
  bucket = var.deployment_log_bucket_name

  tags = {
    Name    = var.deployment_log_bucket_name
    Project = "devops-assignment-4"
  }
}

resource "aws_s3_bucket_versioning" "deployment_logs" {
  bucket = aws_s3_bucket.deployment_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "deployment_logs" {
  bucket = aws_s3_bucket.deployment_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}