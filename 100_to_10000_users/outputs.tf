output "vpc_id" {
  description = "Output for VPC ID"
  value = module.vpc.vpc_id
}

output "ec2_id" {
  description = "Output for EC2 ID"
  value = module.ec2_instance.id
}

output "web_sg_id" {
  description = "Output for my Web Security Group"
  value = aws_security_group.my_sg.id
}

output "db_security_group_id" {
  description = "Output for DB Security Group"
  value = aws_security_group.db_sg.id
}

output "rds_id" {
  description = "Output for my RDS"
  value = module.db.db_instance_name
}