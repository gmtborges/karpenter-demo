variable "cluster_name" {
  default = "aks-demo"
}

variable "resource_group_name" {
  default = "karpenter"
}

variable "location" {
  default = "eastus"
}

variable "karpenter_namespace" {
  default = "kube-system"
}
