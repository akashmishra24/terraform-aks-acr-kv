data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = var.acr_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_key_vault" "key-vault" {
  name                        = var.key_vault_name
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

resource "azurerm_private_endpoint" "kv-endpoint" {
  name                = "${var.key_vault_name}-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.snet.id

  private_service_connection {
    name                           = "${var.key_vault_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.key-vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-endpoint-zone"
    private_dns_zone_ids = [var.private_zone_id]
  }
}
