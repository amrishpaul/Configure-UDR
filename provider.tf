provider "azurerm" {
  subscription_id = "49366f0d-e0f2-4659-a9ab-b02bec7698bf"
  features {}
}
terraform {
  required_version = "~> 0.13"
  required_providers {
    azurerm = "~> 2.0"
  }
}
