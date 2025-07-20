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
    
    ftps_state = "FtpsOnly"
  }
}

# Cria o App Service para o Backend.
resource "azurerm_app_service" "backend_app" {
  name                = "app-vuln-backend-prod-${random_integer.ri.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.app_plan.id

  
  app_settings = {
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "GEMINI_API_KEY"         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.gemini_api_key.id})"
  }

  
  https_only = false
}

# Cria o App Service para o MCP Server.
resource "azurerm_app_service" "mcp_app" {
  name                = "app-vuln-mcp-prod-${random_integer.ri.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.app_plan.id

  
  site_config {
    cors {
      allowed_origins = ["*"]
    }
  }
}
