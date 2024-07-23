resource "azurerm_virtual_network" "hub" {
  provider            = azurerm.hub-sub
  name                = "Hub-Sub-VNet"
  location            = var.location
  resource_group_name = var.hub_rg_name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_virtual_network" "this" {
  provider            = azurerm.spoke-sub
  name                = "${local.prefix}-vnet"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.cidr]
}

resource "azurerm_network_security_group" "this" {
  provider            = azurerm.spoke-sub
  name                = "${local.prefix}-nsg"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_network_security_rule" "aad" {
  provider                    = azurerm.spoke-sub  
  name                        = "AllowAAD"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_network_security_rule" "azfrontdoor" {
  provider                    = azurerm.spoke-sub  
  name                        = "AllowAzureFrontDoor"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_subnet" "public" {
   provider            = azurerm.spoke-sub 
  name                 = "${local.prefix}-public"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 0)]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  provider                  = azurerm.spoke-sub 
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.this.id
}

variable "private_subnet_endpoints" {
  default = []
}

resource "azurerm_subnet" "private" {
  provider             = azurerm.spoke-sub  
  name                 = "${local.prefix}-private"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 1)]

  private_endpoint_network_policies_enabled = true

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }

  service_endpoints = var.private_subnet_endpoints
}

resource "azurerm_subnet_network_security_group_association" "private" {
  provider                  = azurerm.spoke-sub  
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.this.id
}


resource "azurerm_subnet" "plsubnet" {
  provider                                  = azurerm.spoke-sub  
  name                                      = "${local.prefix}-privatelink"
  resource_group_name                       = var.rg_name
  virtual_network_name                      = azurerm_virtual_network.this.name
  address_prefixes                          = [cidrsubnet(var.cidr, 3, 2)]
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_virtual_network_peering" "hubtospoke" {
  provider                  = azurerm.hub-sub  
  name                      = "hubtospoke"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.this.id
}

resource "azurerm_virtual_network_peering" "spoketohub" {
  provider                  = azurerm.spoke-sub  
  name                      = "spoketohub"
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = azurerm_virtual_network.this.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}
