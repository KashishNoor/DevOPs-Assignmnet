output "alb_dns_name" {
  value = aws_lb.bluegreen.dns_name
}

output "production_listener_arn" {
  value = aws_lb_listener.production.arn
}

output "smoke_listener_arn" {
  value = aws_lb_listener.smoke_test.arn
}

output "tg_blue_arn" {
  value = aws_lb_target_group.blue.arn
}

output "tg_green_arn" {
  value = aws_lb_target_group.green.arn
}

output "asg_blue_name" {
  value = aws_autoscaling_group.blue.name
}

output "asg_green_name" {
  value = aws_autoscaling_group.green.name
}

output "lt_blue_id" {
  value = aws_launch_template.blue.id
}

output "lt_green_id" {
  value = aws_launch_template.green.id
}

output "deployment_log_bucket" {
  value = aws_s3_bucket.deployment_logs.bucket
}

output "deployment_log_key" {
  value = "bluegreen/deployments.jsonl"
}