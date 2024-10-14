provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

locals {
  cluster_name        = "aks-demo"
  resource_group_name = "karpenter"
}

resource "helm_release" "karpenter" {
  chart      = "karpenter"
  name       = "karpenter"
  repository = "oci://mcr.microsoft.com/aks/karpenter"
  version    = "0.5.4"
  namespace  = "kube-system"
  values     = [file("karpenter-values.yaml")]
}
