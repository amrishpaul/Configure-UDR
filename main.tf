#Define the Network Resource Group Name
resource "azurerm_resource_group" "rgp-id-prod-niw" {
  name     = "RGP-ID-PROD-NIW"
  location = "northeurope"

  tags = {
    LOB = "NIW"
    environment = "PROD"
  }
}