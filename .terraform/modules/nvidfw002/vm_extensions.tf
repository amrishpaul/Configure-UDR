# Image Bootstrap Script

## Initialize template variables
locals {
  tier        = substr(var.vm_name, 0, 1) == "n" ? "prod" : "staging"
  site        = substr(var.vm_name, 2, 2)
  tier_domain = local.tier != "prod" ? "${local.tier}.nod.nuance.com" : "nod.nuance.com"
  # Auto-Detect DNS servers based on VM name if not explicitely set
  dns_domains = length(var.dns_domains) == 0 ? ["${local.site}.${local.tier_domain}", local.tier_domain] : var.dns_domains

  # Bootstrap config defaults
  bootstrap_defaults = {
    enabled  = true
    source   = "http://linux-yum/NOD"
    os       = "centos7"
    platform = "nvod"
    template = "${path.module}/templates/image_bootstrap.sh.tpl"
  }
  bootstrap_config = merge(local.bootstrap_defaults, var.bootstrap)

  bootstrap_vars = {
    vm_fqdn     = "${var.vm_name}.${local.tier_domain}"
    dns_domains = local.dns_domains
    source      = local.bootstrap_config["source"]
    os          = local.bootstrap_config["os"]
    platform    = local.bootstrap_config["platform"]
  }

  diagnostics_info = {
    storageaccount_name = var.sa_diagnostics != "" ? var.sa_diagnostics.name : ""
    vm_id               = azurerm_linux_virtual_machine.centos_virtual_machine.id
  }

  # Remove leading question mark in SAS token
  sas_token = local.vm_settings["linux_diagnostics"] == true && var.sa_diagnostics != "" ? replace(data.azurerm_storage_account_sas.linux_diagnostics[0].sas, "/^\\?/", "") : ""
}

resource "azurerm_virtual_machine_extension" "centos_virtual_machine_extension_bootstrap" {
  count                = local.vm_settings["bootstrap_enabled"] == true ? 1 : 0
  name                 = "image_bootstrap"
  virtual_machine_id   = azurerm_linux_virtual_machine.centos_virtual_machine.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.centos_virtual_machine_disk_attachment]

  settings = <<SETTINGS
  {
    "script": "${base64encode(templatefile(local.bootstrap_config["template"], local.bootstrap_vars))}"
  }
SETTINGS

  tags = local.tags

  lifecycle {
    ignore_changes = [tags["deployed-by"]]
  }
}

# Linux Diagnostics

# Get SAS Token from Diagnostics Storage Account
data "azurerm_storage_account_sas" "linux_diagnostics" {
  count             = local.vm_settings["linux_diagnostics"] == true ? 1 : 0
  connection_string = var.sa_diagnostics.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = "2019-12-01T00:00:00Z"
  expiry = "2037-12-31T23:59:00Z"

  permissions {
    read    = false
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

resource "azurerm_virtual_machine_extension" "centos_virtual_machine_extension_diagnostics" {
  count                      = local.vm_settings["linux_diagnostics"] == true ? 1 : 0
  name                       = "LinuxDiagnostic"
  virtual_machine_id         = azurerm_linux_virtual_machine.centos_virtual_machine.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "LinuxDiagnostic"
  auto_upgrade_minor_version = true
  type_handler_version       = "3.0"

  settings = templatefile("${path.module}/templates/linux_diagnostics_public_settings.json.tpl", local.diagnostics_info)

  protected_settings = <<SETTINGS
  {
    "storageAccountName": "${var.sa_diagnostics.name}",
    "storageAccountSasToken": "${local.sas_token}"

  }
SETTINGS

  tags = local.tags

  lifecycle {
    ignore_changes = [tags["deployed-by"]]
  }
}
