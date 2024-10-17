resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    vm_size    = "Standard_D2ps_v6"
    name       = "default"
    node_count = 2
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
  }

  identity {
    type = "SystemAssigned"
  }

  # oidc_issuer_enabled       = true
  # workload_identity_enabled = true
}

# resource "azurerm_user_assigned_identity" "karpenter" {
#   name                = "karpentermsi"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = var.location
# }
#
# resource "azurerm_federated_identity_credential" "karpenter" {
#   name                = "KARPENTER_FID"
#   resource_group_name = azurerm_resource_group.this.name
#   audience            = ["api://AzureADTokenExchange"]
#   issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
#   parent_id           = azurerm_user_assigned_identity.karpenter.id
#   subject             = "system:serviceaccount:${var.karpenter_namespace}:karpenter-sa"
# }
#
# resource "azurerm_role_assignment" "karpenter_vm_contributor" {
#   scope                = azurerm_kubernetes_cluster.this.node_resource_group_id
#   role_definition_name = "Virtual Machine Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }
#
# resource "azurerm_role_assignment" "karpenter_network_contributor" {
#   scope                = azurerm_kubernetes_cluster.this.node_resource_group_id
#   role_definition_name = "Network Contributor"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }
#
# resource "azurerm_role_assignment" "karpenter_identity_operator" {
#   scope                = azurerm_kubernetes_cluster.this.node_resource_group_id
#   role_definition_name = "Managed Identity Operator"
#   principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
# }

# Node Auto Provisioning (karpenter add-on)
# First enable NodeAutoProvisioningPreview
# https://learn.microsoft.com/en-gb/azure/aks/node-autoprovision

resource "null_resource" "aks_update" {
  provisioner "local-exec" {
    command = <<EOT
      az aks update \
      --name ${var.cluster_name} \
      --resource-group ${var.resource_group_name} \
      --node-provisioning-mode Auto \
    EOT
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}

