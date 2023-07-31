/*
data "azurerm_public_ip" "pub-ha-prod-vpn-sec" {
  name                = "PIP-HA-FW0001-VPN-SEC-1"
  resource_group_name = "RGP-HA-PROD-NETWORK-FW"
}
*/


# Palo Alto Image in the market place
data "azurerm_platform_image" "paloalto_image_hub_fw" {
  location  = var.location
  publisher = "paloaltonetworks"
  offer     = "vmseries1"
  sku       = "byol"
  version   = "9.1.0"
}

