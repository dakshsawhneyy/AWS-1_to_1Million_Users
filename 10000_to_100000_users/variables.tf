variable "cluster_name" {
  description = "This project is for 10000 to 100000 AWS users"
  default = "10000to100000users"
  type = string
}
variable "project_name" {
  description = "This project is for 10000 to 100000 AWS users"
  default = "10000to100000users"
  type = string
}

variable "vpc_cidr" {
  description = "This provides the cidr block for vpc"
  default = "10.0.0.0/16"
  type = string
}

variable "environment" {
  default = "dev"
  type = string
}

variable "single_nat_gateway" {
  default = true
  type = bool
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}