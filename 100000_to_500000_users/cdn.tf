# This data source will look inside your EKS cluster and find the service created by the NGINX Ingress Controller's Helm chart.
data "kubernetes_service" "ingress_nginx_lb" {
  # This tells the data source to use your aliased provider to connect to the EKS cluster.
  provider = kubernetes.eks_cluster

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  # This ensures Terraform waits for the Helm chart to be fully installed before trying to find the service.
  depends_on = [helm_release.ingress_nginx]
}

resource "aws_cloudfront_distribution" "my_cdn" {
  # This is the main switch to turn the CDN on or off
  enabled = true
  comment = "CDN for Micro Services Project"

  # The origin is the source of truth for your content. In our case, it's our Application Load Balancer.
  origin {
    # A unique ID for this origin
    origin_id   = "EKS-NGINX-${var.project_name}"
    # The public DNS name of your ALB
    domain_name = data.kubernetes_service.ingress_nginx_lb.status[0].load_balancer[0].ingress[0].hostname

    # Configuration for how CloudFront connects to your ALB
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # CloudFront will talk to the ALB over HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # This is the default set of rules for how to cache your content
  default_cache_behavior {
    # This must match the 'origin_id' from the block above
    target_origin_id = "EKS-NGINX-${var.project_name}"

    # Always redirect users from HTTP to HTTPS for security
    viewer_protocol_policy = "redirect-to-https"

    # Define which HTTP methods are allowed
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    # This section defines what is part of the "cache key". We are telling CloudFront to cache based on the URL path, but not query strings or cookies.
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # How long to keep content in the cache (in seconds)
    default_ttl = 60 # Cache for 60 seconds by default
    min_ttl     = 0
    max_ttl     = 300 # Cache for a maximum of 5 minutes
  }

  # This defines the SSL certificate for your CDN. We'll use the default CloudFront certificate for now.
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Only serve content from a limited set of edge locations for cost savings.
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none" # Allow users from all countries
    }
  }

  tags = local.common_tags
}