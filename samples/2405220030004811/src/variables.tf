variable "cidr" {
  type = string
  default = "10.1.0.0/16"
}

variable "rg_name" {
  type = string
  default = "adb-pl-test1-rg"
}

variable "location" {
  type = string
  default = "westeurope"
}

variable "workspace_prefix" {
  type = string
  default = "abd-pl"
}

data "azurerm_client_config" "current" {
}
