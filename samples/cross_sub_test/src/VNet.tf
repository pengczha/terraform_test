resource "azurerm_virtual_network" "hub" {
  provider            = azurerm.hub-sub
  name                = "Hub-VNet"
  location            = var.location
  resource_group_name = var.hub_rg_name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network" "spoke" {
  provider            = azurerm.spoke-sub
  name                = "Spoke-VNet"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [10.2.0.0/16]
}
