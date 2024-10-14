provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../../eks/terraform.tfstate"
  }
}

# resource "helm_release" "karpenter_crd" {
#   chart      = "karpenter-crd"
#   name       = "karpenter-crd"
#   repository = "oci://public.ecr.aws/karpenter"
#   version    = "1.0.6"
#   namespace  = "kube-system"
#
#   set {
#     name  = "webhook.enabled"
#     value = false
#   }
# }

resource "helm_release" "karpenter" {
  chart      = "karpenter"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  version    = "1.0.6"
  namespace  = "kube-system"
  values = [
    templatefile("values.yaml.tftpl",
      {
        eks_name : data.terraform_remote_state.eks.outputs.eks_name,
        eks_endpoint : data.terraform_remote_state.eks.outputs.eks_endpoint
      }
    )
  ]
}
