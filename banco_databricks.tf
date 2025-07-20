# Cria o servidor de Banco de Dados PostgreSQL.
# Erro de Segurança 14: SSL não é forçado, permitindo conexões não criptografadas.
resource "azurerm_postgresql_server" "postgres" {
  name                         = "psql-vuln-graphdb-prod"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  version                      = "11"
  administrator_login          = "psqladmin"

  # Erro de Segurança 15: Senha do administrador hardcoded.
  administrator_login_password = "SuperVulnerablePassword123!"

  ssl_enforcement_enabled = false
}

# Erro de Segurança 16: Regra de firewall do banco de dados permite acesso de qualquer IP do Azure.
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

  # Erro de Design/Segurança 17: Workspace do Databricks sem injeção de VNet,
  # o que o expõe à rede pública por padrão.
}