module "acr" {
  source               = ".//acr-module"
  acr_name             = var.acr_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  virtual_network_name = var.virtual_network_name
  acr_subnet_name      = var.acr_subnet_name
  private_zone_id      = var.private_zone_id
}

module "kv" {
  source               = ".//kv-module"
  key_vault_name       = var.key_vault_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  acr_subnet_name      = var.acr_subnet_name
  private_zone_id      = var.private_zone_id
  tenant_id            = var.tenant_id
}

module "aks" {
  source               = ".//aks-module"
  depends_on           = [module.acr, module.kv]
  aks_name             = var.aks_name
  resource_group_name  = var.resource_group_name
  location             = "East US"
  virtual_network_name = var.virtual_network_name
  subnet_name          = var.subnet_name
  dns_prefix           = var.dns_prefix
  kubernetes_version   = var.kubernetes_version
  sku_tier             = var.sku_tier
  dns_service_ip       = var.dns_service_ip
  docker_bridge_cidr   = var.docker_bridge_cidr
  enable_oms_agent     = false
  log_workspace_id     = var.log_workspace_id
  key_vault_rg_name    = var.resource_group_name
  acr_rg_name          = var.resource_group_name
  acr_name             = var.acr_name
  key_vault_name       = var.key_vault_name
  private_zone_id      = var.private_zone_id
  linux_admin_username = var.linux_admin_username
  linux_ssh_key = var.linux_ssh_key
  user_assigned_mi = ["/subscriptions/7b5c7d11-8bc3-4105-9c6f-41222b38b95f/resourceGroups/rg-iac-cox-poc-01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/iac-cox-poc-mi-01"]
}
