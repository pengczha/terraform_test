variable "cidr" {
  type = string
  default = "10.1.0.0/16"
}

variable "rg_name" {
  type = string
  default = "abd-pl-rg"
}

variable "location" {
  type = string
  default = "westeurope"
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  prefix = "abd-pl"
  tags = {
    Environment = "Demo"
    Owner       = lookup(data.external.me.result, "name")
  }
}
