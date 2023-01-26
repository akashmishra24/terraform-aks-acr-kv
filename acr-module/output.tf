output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "custom_dns_configs" {
  value = azurerm_private_endpoint.acr-endpoint.custom_dns_configs
}
