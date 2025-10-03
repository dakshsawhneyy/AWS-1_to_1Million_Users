output "vpc_id" {
  description = "Output for VPC ID"
  value = module.vpc.vpc_id
}

output "ec2_id" {
  description = "Output for EC2 ID"
  value = module.ec2_instance.id
}

output "my_sg_id" {
  description = "Output for my Security Group"
  value = aws_security_group.my_sg.id
}
