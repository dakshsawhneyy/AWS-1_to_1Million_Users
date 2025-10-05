variable "cluster_name" {
  description = "This project is for 10000 to 100000 AWS users"
  default = "100000_to_500000_users"
  type = string
}
variable "project_name" {
  description = "This project is for 10000 to 100000 AWS users"
  default = "100000_to_500000_users"
  type = string
}

variable "vpc_cidr" {
  description = "This provides the cidr block for vpc"
  #default = "10.0.0.0/16"
  type = string
}

variable "environment" {
  #default = "dev"
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
  #default     = "ap-south-1"
}

variable "argocd_namespace" {
  description = "Namespace to install ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

# variable "replication_group_id" {
#   description = "The unique ID for the Redis replication group"
#   type        = string
#   default     = "redis-cluster"
# }

variable "replicate_source_db_arn" {
  description = "The ARN of the source DB to replicate from."
  type        = string
  default     = null # This makes it optional
}