terraform {
  backend "azurerm" {
    storage_account_name = "staidprodterraform002"
    container_name       = "idprodniwterraformstate"
    key                  = "id-prod-niw.terraform.tfstate"
    subscription_id      = "a47ed438-a3db-44fc-9362-e9e51c0f1bd7"
    resource_group_name  = "RGP-ID-NETWORK-NPOD-PROD1"
  }
}
