# Data Disks
locals {
  datadisk_default_settings = {
    name          = ""
    create_option = "Empty"
    caching       = "ReadWrite"
    lun           = -1
  }

  datadisk_varlog = var.enable_datadisk_varlog ? [{ name = "${var.vm_name}_datadisk0-varlog", disk_type = "Standard_LRS", size = var.varlog_disk_size_gb }] : []

  data_disks = [
    for disk in concat(local.datadisk_varlog, var.data_disks) :
    merge(local.datadisk_default_settings, disk)
  ]
}

resource "azurerm_managed_disk" "centos_virtual_machine_datadisk" {
  count                = length(local.data_disks)
  name                 = local.data_disks[count.index].name != "" ? local.data_disks[count.index].name : "${var.vm_name}_datadisk${count.index}"
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
  storage_account_type = local.data_disks[count.index].disk_type
  create_option        = local.data_disks[count.index].create_option
  disk_size_gb         = local.data_disks[count.index].create_option == "Empty" ? local.data_disks[count.index].size : ""
  image_reference_id   = local.data_disks[count.index].create_option == "FromImage" ? local.data_disks[count.index].image_id : ""
  tags                 = local.tags

  lifecycle {
    ignore_changes = [tags["deployed-by"]]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "centos_virtual_machine_disk_attachment" {
  count              = length(local.data_disks)
  managed_disk_id    = azurerm_managed_disk.centos_virtual_machine_datadisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.centos_virtual_machine.id
  lun                = local.data_disks[count.index].lun != -1 ? local.data_disks[count.index].lun : count.index
  caching            = local.data_disks[count.index].caching
}