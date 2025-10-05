# =============================================================================
# Security Groups CONFIGURATION
# =============================================================================
resource "aws_security_group" "cache_sg" {
  name = "${var.project_name}-cache_sg"
  description = "Allows SSH and HTTP traffic in Cache"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"

    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# =============================================================================
# Elastic Cache CONFIGURATION
# =============================================================================

# Use the ElastiCache module to create a Redis cluster
module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  replication_group_id = "redis-elasticache"

  cluster_id           = "hello-redis"
  engine = "redis"
  engine_version = "7.1"
  node_type      = "cache.t3.micro"
  num_cache_nodes = 1

  # Place cache in private subnets
  subnet_ids = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id
  security_group_ids = [aws_security_group.cache_sg.id]

  tags = local.common_tags
}