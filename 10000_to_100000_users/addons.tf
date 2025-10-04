# # =============================================================================
# # EKS ADD-ONS AND EXTENSIONS
# # =============================================================================

# module "eks_addons" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.0"

#   # Cluster information
#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   eks_addons = {
#     aws-ebs-csi-driver = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#   }

#   providers = {
#     helm = helm.eks_cluster
#   }

#   # =============================================================================
#   # CERT-MANAGER - SSL Certificate Management
#   # =============================================================================
#   enable_cert_manager = true
#   cert_manager = {
#     most_recent = true
#     namespace   = "cert-manager"
#   }

#   # =============================================================================
#   # NGINX INGRESS CONTROLLER - Load Balancing and Routing
#   # =============================================================================
#   enable_ingress_nginx = true
#   ingress_nginx = {
#     most_recent = true
#     namespace   = "ingress-nginx"
    
#     # Basic configuration
#     set = [
#       {
#         name  = "controller.service.type"
#         value = "LoadBalancer"
#       },
#       {
#         name  = "controller.service.externalTrafficPolicy"
#         value = "Local"
#       },
#       {
#         name  = "controller.resources.requests.cpu"
#         value = "100m"
#       },
#       {
#         name  = "controller.resources.requests.memory"
#         value = "128Mi"
#       },
#       {
#         name  = "controller.resources.limits.cpu"
#         value = "200m"
#       },
#       {
#         name  = "controller.resources.limits.memory"
#         value = "256Mi"
#       }
#     ]
    
#     # AWS Load Balancer specific annotations
#     set_sensitive = [
#       {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
#         value = "internet-facing"
#       },
#       {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
#         value = "nlb"
#       },
#       {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
#         value = "instance"
#       },
#       {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-path"
#         value = "/healthy"
#       },
#       {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-port"
#         value = "10254"
#       },
#       {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-protocol"
#         value = "HTTP"
#       }
#     ]
#   }

#   # =============================================================================
#   # OPTIONAL: MONITORING STACK
#   # =============================================================================
#   # Uncomment below to enable monitoring (increases costs)
  
#   # enable_kube_prometheus_stack = var.enable_monitoring
#   # kube_prometheus_stack = {
#   #   most_recent = true
#   #   namespace   = "monitoring"
#   # }

#   # =============================================================================
#   # OPTIONAL: AWS LOAD BALANCER CONTROLLER
#   # =============================================================================
#   # enable_aws_load_balancer_controller = true
#   # aws_load_balancer_controller = {
#   #   most_recent = true
#   #   namespace   = "kube-system"
#   # }

#   depends_on = [module.eks]
# }

# addons.tf

resource "helm_release" "cert_manager" {
  # This tells Terraform to use the aliased provider we created
  provider = helm.eks_cluster

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.14.5" # Use a specific, stable version

  set = [
    {
      name  = "installCRDs"
      value = "true"
    }
  ]
}

resource "helm_release" "ingress_nginx" {
  # This also tells Terraform to use the aliased provider
  provider = helm.eks_cluster

  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.1" # Use a specific, stable version

  set = [
    {
        name  = "controller.service.type"
        value = "LoadBalancer"
    },
    {
        name  = "controller.service.externalTrafficPolicy"
        value = "Local"
    },
    {
        name  = "controller.resources.requests.cpu"
        value = "100m"
    },
    {
        name  = "controller.resources.requests.memory"
        value = "128Mi"
    },
    {
        name  = "controller.resources.limits.cpu"
        value = "200m"
    },
    {
        name  = "controller.resources.limits.memory"
        value = "256Mi"
    },
    {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
        value = "internet-facing"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "nlb"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
        value = "instance"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-path"
        value = "/healthy"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-port"
        value = "10254"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-protocol"
        value = "HTTP"
      }
  ]
}