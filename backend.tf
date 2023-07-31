#terraform init -backend-config="beconf.tfvars"
terraform {
  backend "azurerm" {
    storage_account_name = "staidprodterraform002"
    container_name       = "proddmzterraformstate"
    key                  = "id-prod-hub-firewall-azure.terraform.tfstate"
  }
}


