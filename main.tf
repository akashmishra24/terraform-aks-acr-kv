module "aks" {
  source               = ".//aks-module"
  depends_on = [module.acr, module.kv]
  aks_name             = var.aks_name
  resource_group_name  = var.resource_group_name
  location             = "East US 2"
  virtual_network_name = var.virtual_network_name
  subnet_name          = var.subnet_name
  dns_prefix           = var.dns_prefix
  kubernetes_version   = var.kubernetes_version
  sku_tier             = var.sku_tier
  dns_service_ip       = var.dns_service_ip
  docker_bridge_cidr   = var.docker_bridge_cidr
  enable_oms_agent     = false
  log_workspace_id     = var.log_workspace_id
  key_vault_rg_name = var.resource_group_name
  acr_rg_name = var.resource_group_name
  acr_name = var.acr_name
  key_vault_name = var.key_vault_name
  private_zone_id      = var.private_zone_id
}
