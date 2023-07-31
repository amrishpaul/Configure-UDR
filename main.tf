#terraform init -backend-config="beconf.tfvars"
resource "azurerm_resource_group" "rgp_id_prod_hub_fw" {
  name     = "RGP-ID-PROD-HUB-FW"
  location = var.location
  tags     = var.tags
}
