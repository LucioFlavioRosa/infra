# Cria uma conta de armazenamento para os blobs.

resource "azurerm_storage_account" "storage" {
  name                     = "stvulnappprod${random_integer.ri.id}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  
  min_tls_version = "TLS1_0"
}

resource "azurerm_storage_container" "public_data" {
  name                  = "public-data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob" # Permite acesso público anônimo
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
