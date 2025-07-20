# Cria o servidor de Banco de Dados PostgreSQL.

resource "azurerm_postgresql_server" "postgres" {
  name                         = "psql-vuln-graphdb-prod"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  version                      = "11"
  administrator_login          = "psqladmin"

  
  administrator_login_password = "SuperVulnerablePassword123!"

  ssl_enforcement_enabled = false
}


resource "azurerm_postgresql_firewall_rule" "allow_azure" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.postgres.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Cria o workspace do Azure Databricks.
resource "azurerm_databricks_workspace" "databricks" {
  name                = "dbw-vulnapp-prod-${random_integer.ri.id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"

  
  # o que o expõe à rede pública por padrão.
}
