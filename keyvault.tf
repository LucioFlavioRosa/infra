# Cria o Azure Key Vault.
# Erro de Segurança 5: Soft delete não está ativado, permitindo a exclusão permanente e imediata de segredos.
resource "azurerm_key_vault" "keyvault" {
  name                        = "kv-vulnapp-prod-${random_integer.ri.id}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  # Erro de Segurança 6: Acesso à rede permitido de qualquer lugar. Deveria ser restrito.
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

data "azurerm_client_config" "current" {}

# Armazena a chave da API do Gemini como um segredo no Key Vault.
# Erro de Segurança 7: A chave da API está hardcoded no código.
resource "azurerm_key_vault_secret" "gemini_api_key" {
  name         = "GeminiApiKey"
  value        = "ai-vuln-api-key-hardcoded-in-tf"
  key_vault_id = azurerm_key_vault.keyvault.id
}