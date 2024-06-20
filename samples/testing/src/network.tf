provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "Databricks-RG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "Spoke" {
  name                = "Spoke-VNet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_virtual_network" "Hub" {
  name                = "Hub-VNet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "dbrpub" {
  name                 = "pub-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.Spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "dbrpri" {
  name                 = "pri-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.Spoke.name
  address_prefixes     = ["10.1.2.0/24"]
}
