terraform {
  required_version = "> 0.13"
  required_providers {
    azurerm = "~> 2.0"
    environment = {
      source  = "EppO/environment"
      version = "~> 1.1.0"
    }
  }
}