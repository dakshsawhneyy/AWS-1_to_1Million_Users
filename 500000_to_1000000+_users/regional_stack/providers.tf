# =============================================================================
# PROVIDER CONFIGURATIONS
# =============================================================================

provider "aws" {
  region = var.aws_region
}

# Terraform doesn't fail at terraform init or terraform plan when it sees resources that require those providers but the EKS cluster isn't created yet.
provider "kubernetes" {}
provider "helm" {}

provider "kubernetes" {
  alias = "eks_cluster"   # dummy provider so Terraform doesn't fail at plan time because eks cluster hasn't built yet
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  alias = "eks_cluster"
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}