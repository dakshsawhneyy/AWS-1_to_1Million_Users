resource "time_sleep" "wait_for_cluster_ready" {
  create_duration = "300s"
  depends_on = [module.eks.eks_managed_node_group]
}

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

  timeout = 900 # Wait up to 600 seconds (10 minutes)

  depends_on = [time_sleep.wait_for_cluster_ready]
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
  ]

  timeout = 900 # Wait up to 600 seconds (10 minutes)

  depends_on = [time_sleep.wait_for_cluster_ready]
}