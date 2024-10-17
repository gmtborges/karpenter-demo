provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "karpenter" {
  chart      = "karpenter"
  name       = "karpenter"
  repository = "oci://mcr.microsoft.com/aks/karpenter"
  version    = "0.5.1"
  namespace  = "kube-system"
  values     = [file("karpenter-values.yaml")]
}
