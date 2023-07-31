#terraform init -backend-config="beconf.tfvars"

resource "azurerm_storage_account" "bootdiag_hub_fw" {
  name                      = "staidprodhubfwbootdiags"
  resource_group_name       = azurerm_resource_group.rgp_id_prod_hub_fw.name
  location                  = azurerm_resource_group.rgp_id_prod_hub_fw.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  tags                      = var.tags

}
