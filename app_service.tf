# Cria os planos de serviço para as aplicações.
resource "azurerm_service_plan" "app_plan" {
  name                = "asp-vulnerable-app-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Cria o App Service para o Frontend.
resource "azurerm_app_service" "frontend_app" {
  name                = "app-vuln-frontend-prod-${random_integer.ri.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.app_plan.id

  site_config {
    # Erro de Segurança 8: FTP está habilitado, o que é um protocolo inseguro.
    ftps_state = "FtpsOnly"
  }
}

# Cria o App Service para o Backend.
resource "azurerm_app_service" "backend_app" {
  name                = "app-vuln-backend-prod-${random_integer.ri.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.app_plan.id

  # Erro de Design 9: Ausência de configuração de VNet integration para comunicação privada.
  app_settings = {
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "GEMINI_API_KEY"         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gemini_api_key.id})"
  }

  # Erro de Segurança 10: HTTPS Only está desabilitado, permitindo tráfego HTTP.
  https_only = false
}

# Cria o App Service para o MCP Server.
resource "azurerm_app_service" "mcp_app" {
  name                = "app-vuln-mcp-prod-${random_integer.ri.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.app_plan.id

  # Erro de Segurança 11: CORS (Cross-Origin Resource Sharing) configurado para permitir qualquer origem.
  site_config {
    cors {
      allowed_origins = ["*"]
    }
  }
}