terraform {
  backend "azurerm" {
    resource_group_name  = "rg-iac-cox-poc-01"
    storage_account_name = "tfstatedemo1"
    container_name       = "tfstate"
    key                  = "terraform_aks_poc.tfstate"
  }
}

terraform {
  required_version = "1.3.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}
