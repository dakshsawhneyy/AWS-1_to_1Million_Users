variable "project_name" {
  description = "This project is for 1 to 100 AWS users"
  default = "1to100users"
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