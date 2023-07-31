terraform {
  backend "azurerm" {
    storage_account_name = "staidprodterraform002"
    container_name       = "idprodniwterraformstate"
    key                  = "id-prod-niw.terraform.tfstate"
    subscription_id      = "49366f0d-e0f2-4659-a9ab-b02bec7698bf"
    resource_group_name  = "RGP-ID-NETWORK-NPOD-PROD1"
  }
}
