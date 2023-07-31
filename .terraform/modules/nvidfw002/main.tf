# Virtual machine
locals {
  vm_default_settings = {
    "bootstrap_enabled"       = true
    "accelerated_networking"  = false
    "boot_diagnostics"        = true
    "linux_diagnostics"       = false
    "msi_enabled"             = false
    "password_authentication" = true
  }
  vm_settings = merge(local.vm_default_settings, var.vm_settings)
}

resource "azurerm_linux_virtual_machine" "centos_virtual_machine" {
  name                            = var.vm_name
  location                        = var.resource_group.location
  resource_group_name             = var.resource_group.name
  network_interface_ids           = azurerm_network_interface.nic.*.id
  size                            = var.vm_size
  admin_username                  = var.admin["name"]
  admin_password                  = var.admin["password"]
  disable_password_authentication = !local.vm_settings["password_authentication"]
  availability_set_id             = var.availability_set_id
  source_image_id                 = var.image_id
  custom_data                     = var.custom_data

  lifecycle {
    ignore_changes = [custom_data, tags["deployed-by"]]
  }

  dynamic "plan" {
    for_each = length(var.plan) != 0 ? [var.plan] : []

    content {
      name      = plan.value.name
      publisher = plan.value.publisher
      product   = plan.value.product
    }
  }

  dynamic "source_image_reference" {
    for_each = var.image_id != null ? [] : [var.os]

    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  os_disk {
    name                 = "${var.vm_name}_vmdisk"
    storage_account_type = var.vm_disk_type
    caching              = "ReadWrite"
    disk_size_gb         = var.os_disk_size_gb
  }

  dynamic "boot_diagnostics" {
    for_each = local.vm_settings["boot_diagnostics"] == true && var.sa_diagnostics != "" ? [var.sa_diagnostics.primary_blob_endpoint] : []

    content {
      storage_account_uri = substr(boot_diagnostics.value, -1, 1) == "/" ? substr(boot_diagnostics.value, 0, length(boot_diagnostics.value) - 1) : boot_diagnostics.value
    }
  }

  dynamic "identity" {
    for_each = local.vm_settings["msi_enabled"] == true ? ["SystemAssigned"] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = local.tags
}
