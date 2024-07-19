locals {
  prefix = "abd-pl"
}

resource "azurerm_private_endpoint" "uiapi" {
  provider            = azurerm.spoke-sub
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
  provider            =  azurerm.hub-sub
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = var.hub_rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "uiapidnszonevnetlink" {
  name                  = "uiapispokevnetconnection"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsuiapi.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet
}


resource "azurerm_private_dns_zone_virtual_network_link" "uiapidnszonevnetlinkwithhub" {
  provider              = azurerm.hub-sub
  name                  = "uiapihubvnetconnection"
  resource_group_name   = var.hub_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsuiapi.name
  virtual_network_id    = azurerm_virtual_network.hub.id // connect to hub vnet
}

resource "azurerm_private_endpoint" "auth" {
  provider            = azurerm.spoke-sub
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
}

resource "azurerm_databricks_workspace" "this" {
  provider                              = azurerm.spoke-sub
  name                                  = "${local.prefix}-workspace"
  resource_group_name                   = var.rg_name
  location                              = var.location
  sku                                   = "premium"
  public_network_access_enabled         = true
  network_security_group_rules_required = "NoAzureDatabricksRules"
  customer_managed_key_enabled          = true
  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    storage_account_name                                 = "dbfsadbpl"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}
