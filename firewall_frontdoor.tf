# Cria um IP público para o Firewall.
resource "azurerm_public_ip" "firewall_ip" {
  name                = "pip-firewall-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Cria o Azure Firewall.
resource "azurerm_firewall" "firewall" {
  name                = "fw-vulnerable-app-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_ip.id
  }
}

# Cria uma política de Firewall.
resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "fw-policy-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_firewall_application_rule_collection" "allow_all_web" {
  name                = "AllowAllWeb"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "AllowAnyHTTP"
    source_addresses = ["*"]
    target_fqdns     = ["*"]
    protocol {
      type = "Http"
      port = 80
    }
  }
  rule {
    name = "AllowAnyHTTPS"
    source_addresses = ["*"]
    target_fqdns     = ["*"]
    protocol {
      type = "Https"
      port = 443
    }
  }
}

# Cria o Azure Front Door.
resource "azurerm_frontdoor" "frontdoor" {
  name                = "fd-vulnapp-prod-${random_integer.ri.id}"
  resource_group_name = azurerm_resource_group.rg.name

  routing_rule {
    name               = "defaultRoutingRule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["defaultFrontendEndpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "defaultBackendPool"
    }
  }

  backend_pool {
    name = "defaultBackendPool"
    backend {
      host_header = azurerm_app_service.frontend_app.default_site_hostname
      address     = azurerm_app_service.frontend_app.default_site_hostname
      http_port   = 80
      https_port  = 443
    }
    
    health_probe {
      path                = "/"
      protocol            = "Http"
      interval_in_seconds = 240
    }
  }

  frontend_endpoint {
    name      = "defaultFrontendEndpoint"
    host_name = "${azurerm_frontdoor.frontdoor.name}.azurefd.net"
  }
}
