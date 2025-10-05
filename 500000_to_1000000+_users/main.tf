module "mumbai_stack" {
  source = "./regional_stack"
  
  aws_region = "ap-south-1"
  environment = "dev"
  vpc_cidr = "10.0.0.0/16"
}

module "virginia_stack" {
  source = "./regional_stack"
  
  # This is the magic! We are telling the Virginia stack to replicate the database from the Mumbai stack.
  replicate_source_db_arn = module.mumbai_stack.rds_cluster_arn

  aws_region = "us-east-1"
  environment = "dev"
  vpc_cidr = "10.1.0.0/16"
}

# =============================================================================
# Route53 Configuration
# =============================================================================

# Create a public DNS zone for your domain
resource "aws_route53_zone" "primary" {
  name = "aws.dakshsawhneyy.online" # Replace with your actual domain name
}

# Route53 Record for Mumbai Region
resource "aws_route53_record" "mumbai" {
  zone_id = aws_route53_zone.primary.zone_id
  name = "aws.dakshsawhneyy.online"
  type    = "A"

  latency_routing_policy {
    region = "ap-south-1"
  }

  set_identifier = "mumbai-primary"   # unique id

  # This links the DNS record to the load balancer in your Mumbai stack
  alias {
    name                   = module.mumbai_stack.alb_dns_name
    zone_id                = module.mumbai_stack.alb_zone_id
    evaluate_target_health = true
  }
}

# Route53 Record for Virginia Region
resource "aws_route53_record" "virginia_stack" {
  zone_id = aws_route53_zone.primary.zone_id
  name = "aws.dakshsawhneyy.online"
  type    = "A"

  latency_routing_policy {
    region = "us-east-1"
  }

  set_identifier = "virginia-primary"   # unique id

  # This links the DNS record to the load balancer in your Mumbai stack
  alias {
    name                   = module.virginia_stack.alb_dns_name
    zone_id                = module.virginia_stack.alb_zone_id
    evaluate_target_health = true
  }
}