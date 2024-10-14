resource "azurerm_resource_group" "karpenter_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "karpentermsi" {
  name                = "karpentermsi"
  resource_group_name = azurerm_resource_group.karpenter_rg.name
  location            = var.location
}

resource "azurerm_kubernetes_cluster" "karpenter_aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.karpenter_rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    vm_size    = "Standard_D2ps_v5"
    name       = "default"
    node_count = 2
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
  }
}

resource "azurerm_role_assignment" "karpenter_vm_contributor" {
  principal_id         = azurerm_user_assigned_identity.karpentermsi.principal_id
  scope                = azurerm_kubernetes_cluster.karpenter_aks.node_resource_group_id
  role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_role_assignment" "karpenter_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.karpentermsi.principal_id
  scope                = azurerm_kubernetes_cluster.karpenter_aks.node_resource_group_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "karpenter_identity_operator" {
  principal_id         = azurerm_user_assigned_identity.karpentermsi.principal_id
  scope                = azurerm_kubernetes_cluster.karpenter_aks.node_resource_group_id
  role_definition_name = "Managed Identity Operator"
}
