output "vpc_id" {
  description = "Output for VPC ID"
  value = module.vpc.vpc_id
}

output "load_balancer_ip" {
  description = "The public URL for the application load balancer."
  value = "https://${aws_lb.my_lb.dns_name}"
}

output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group."
  value       = aws_autoscaling_group.my_asg.name
}

output "web_sg_id" {
  description = "Output for my Web Security Group"
  value = aws_security_group.web_sg.id
}

output "db_security_group_id" {
  description = "Output for DB Security Group"
  value = aws_security_group.db_sg.id
}

output "rds_id" {
  description = "Output for my RDS"
  value = module.db.db_instance_name
}