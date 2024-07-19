terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0"
    }
  }
}


provider "azurerm" {
  alias = "hub-sub"
  subscription_id = "792791c0-485d-4465-9c4b-e2c10fa9c810"
  tenant_id = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  client_id = "db9af9ca-7fc8-4050-ab31-c3bbd6f28899"
  features {}
}
provider "azurerm" {
  alias = "spoke-sub"
  subscription_id = "5f0f314b-4646-4212-ac9f-1b1de1860bcd"
  tenant_id = "16b3c013-d300-468d-ac64-7eda0820b6d3"
  client_id = "db9af9ca-7fc8-4050-ab31-c3bbd6f28899"
  features {}
}
