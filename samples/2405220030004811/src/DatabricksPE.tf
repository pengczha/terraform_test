locals {
  prefix = "abd-pl"
}

resource "azurerm_private_endpoint" "uiapi" {
  name                = "uiapipvtendpoint"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-uiapi"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-uiapi"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsuiapi.id]
  }
}

resource "azurerm_private_dns_zone" "dnsuiapi" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "uiapidnszonevnetlink" {
  name                  = "uiapispokevnetconnection"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsuiapi.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}

resource "azurerm_private_endpoint" "auth" {
  name                = "aadauthpvtendpoint"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-auth"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-auth"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsuiapi.id]
  }

  depends_on = [azurerm_private_endpoint.uiapi]
}
