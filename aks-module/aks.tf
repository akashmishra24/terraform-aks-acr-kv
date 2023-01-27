data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg_name
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_rg_name
}

# resource "azurerm_private_dns_zone" "aks_dns" {
#   count               = var.private_cluster_enabled == true ? 1 : 0
#   name                = "akspoc.com"
#   resource_group_name = data.azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "hub_aks" {
#   name                  = "hub_to_aks"
#   resource_group_name   = data.azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.aks_dns[0].name
#   virtual_network_id    = data.azurerm_virtual_network.vnet.id
# }

resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns" {
  name                  = "aks-dns"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = "akspoc.com"
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}

resource "azurerm_log_analytics_workspace" "this" {
  count = var.enable_oms_agent == true ? 1 : 0

  name                = "law-${var.dns_prefix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "this" {
  count                 = var.enable_oms_agent == true ? 1 : 0
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.this.0.id
  workspace_name        = azurerm_log_analytics_workspace.this.0.name
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_kubernetes_cluster" "this" {
  name                                = var.aks_name
  location                            = data.azurerm_resource_group.rg.location
  resource_group_name                 = data.azurerm_resource_group.rg.name
  dns_prefix                          = var.dns_prefix
  kubernetes_version                  = var.kubernetes_version
  sku_tier                            = var.sku_tier
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_zone_id # var.private_cluster_enabled == true ? azurerm_private_dns_zone.aks_dns.0.id : null
  azure_policy_enabled                = false
  http_application_routing_enabled    = false
  role_based_access_control_enabled   = false
  private_cluster_public_fqdn_enabled = false
  public_network_access_enabled       = false # var.public_network_access_enabled

  default_node_pool {
    name                   = "default"
    node_count             = var.default_node_pool_node_count
    vm_size                = var.default_node_pool_vm_size # "Standard_DS2_v2"
    zones                  = var.default_node_pool_availability_zones
    enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
    min_count              = var.default_node_pool_min_count
    max_count              = var.default_node_pool_max_count
    max_pods               = var.default_node_pool_max_pods
    os_disk_type           = var.default_node_pool_os_disk_type
    enable_host_encryption = var.default_node_pool_enable_host_encryption
    enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
    os_disk_size_gb        = var.default_node_pool_os_disk_size_gb
    type                   = "VirtualMachineScaleSets"
    vnet_subnet_id         = data.azurerm_subnet.snet.id
    node_taints            = var.default_node_pool_node_taints
    node_labels            = var.default_node_pool_node_labels
    tags                   = var.tags
  }

  linux_profile {
    admin_username = var.linux_admin_username
    ssh_key {
      key_data = var.linux_ssh_key
    }
  }

  # dynamic "windows_profile" {
  #   for_each = var.windows_profile
  #   content {
  #     admin_username = lookup(var.windows_profile, "admin_username", "aks-admin")
  #     admin_password = lookup(var.windows_profile, "admin_password", null)
  #     license = 
  #   }
  # }

  # service_principal {
  #   client_id     = var.service_principal.client_id != null ? var.service_principal.client_id : null
  #   client_secret = var.service_principal.client_id != null ? var.service_principal.client_secret : null
  # }
  # Either of 'Service Principal' or 'Identity' can exist at a time

  identity {
    type         = var.user_assigned_mi == null ? "SystemAssigned" : "UserAssigned"
    identity_ids = var.user_assigned_mi == null ? null : var.user_assigned_mi
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    tenant_id              = var.tenant_id
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway
    content {
      gateway_id   = lookup(var.ingress_application_gateway, "gateway_id", null)
      gateway_name = lookup(var.ingress_application_gateway, "gateway_name", null)
      subnet_cidr  = lookup(var.ingress_application_gateway, "subnet_cidr", null)
      subnet_id    = lookup(var.ingress_application_gateway, "subnet_id", null)
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    network_mode = "transparent"
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    outbound_type      = var.outbound_type
    pod_cidr           = var.pod_cidr
    service_cidr       = var.service_cidr
  }

  oms_agent {
    log_analytics_workspace_id = var.log_workspace_id
  }

  dynamic "http_proxy_config" {
    for_each = var.aks_http_proxy_settings
    content {
      http_proxy  = var.aks_http_proxy_settings.http_proxy_url
      https_proxy = var.aks_http_proxy_settings.https_proxy_url
      no_proxy    = var.aks_http_proxy_settings.no_proxy_url_list
      trusted_ca  = var.aks_http_proxy_settings.trusted_ca
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile
    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      expander                         = auto_scaler_profile.value.expander
      max_graceful_termination_sec     = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time       = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage           = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay           = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add       = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete    = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure   = auto_scaler_profile.value.scale_down_delay_after_failure
      scan_interval                    = auto_scaler_profile.value.scan_interval
      scale_down_unneeded              = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready               = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      empty_bulk_delete_max            = auto_scaler_profile.value.empty_bulk_delete_max
      skip_nodes_with_local_storage    = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  # api_server_access_profile {
  #     authorized_ip_ranges     = var.public_network_access_enabled == true ? ["0.0.0.0/32"] : null
  #     subnet_id                = var.public_network_access_enabled == true ? var.subnet_id : null
  #     vnet_integration_enabled = var.public_network_access_enabled == true ? var.vnet_integration_enabled : null
  #   }
  tags = var.tags
}

resource "azurerm_role_assignment" "aks_kv_role" {
  scope                            = data.azurerm_key_vault.kv.id
  role_definition_name             = "Reader"
  principal_id                     = azurerm_kubernetes_cluster.this.identity.0.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_acr_role" {
  scope                            = data.azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.this.identity.0.principal_id
  skip_service_principal_aad_check = true
}
