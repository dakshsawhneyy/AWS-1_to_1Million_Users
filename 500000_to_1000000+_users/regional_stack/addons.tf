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

  depends_on = [ module.eks ]
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

  depends_on = [ module.eks ]
}