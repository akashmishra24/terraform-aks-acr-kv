output "kv_id" {
  value = azurerm_key_vault.key-vault.id
}

output "key_vault_url" {
  value = azurerm_key_vault.key-vault.vault_uri
}
