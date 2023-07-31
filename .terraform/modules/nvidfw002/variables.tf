variable "resource_group" {
  description = "(Required) Resource group where the resources will be created. Resourge group name and location will be used for other resources created within."
}

variable "nics" {
  description = "(Required if ip_address and subnet_id not provided) List of IP addresses/Subnet IDs for VM NICs. IP Address can be a string or a list of strings."
  type = list(object({
    ip_address = list(map(string))
    subnet_id  = string
    settings   = map(string)
  }))

  default = []
}

variable "ip_address" {
  description = "(Required if nics not provided) IP address of the NIC"
  type        = string

  default = null
}

variable "subnet_id" {
  description = "(Required if nics not provided) Subnet ID of the IP Address"
  type        = string

  default = null
}

variable "vm_name" {
  description = "(Required) Name of the virtual machine"
}

variable "vm_size" {
  description = "(Required) Size of the vm. To see full list run 'az vm list-sizes'"
}

variable "dns_domains" {
  description = "(Required) DNS Search list for hostname lookup."
  type        = list(string)

  default = []
}

variable "admin" {
  description = "Default user with root access"
  type = object({
    name       = string
    public_key = string
    password   = string
  })

  default = {
    name       = "nod_admin"
    public_key = ""
    password   = "NODpassword123!"
  }
}

variable "vm_disk_type" {
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."

  default = "StandardSSD_LRS"
}

variable "data_disks" {
  description = "List of additional disks to attach to the VM."
  type        = list(map(string))

  default = []
}

variable "enable_datadisk_varlog" {
  description = "Whether or not including a datadisk for /var/log partition."
  type        = bool

  default = true
}

variable "varlog_disk_size_gb" {
  description = "Size of /var/log datadisk if enable_datadisk_varlog is set to true."
  type        = number

  default = 20
}

variable "os" {
  description = "Disk image with preinstalled OS"
  type        = map(any)

  default = {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "7.9.2020111900"
  }
}

variable "image_id" {
  description = "The id of the image to be installed."

  default = null
}

variable "availability_set_id" {
  description = "The ID of the Availability Set in which the Virtual Machine should exist."

  default = null
}

variable "os_disk_size_gb" {
  description = "Size of OS data disk. Use image size if not set."

  default = null
}

variable "vm_settings" {
  description = "VM Settings in order to override defaults"
  type        = map(any)

  default = {}
}

variable "sa_diagnostics" {
  description = "Storage account for the Boot and Guest Linux VM Diagnostics"

  default = ""
}

variable "plan" {
  description = "Image billing plan"
  type        = map(string)

  default = {}
}

variable "tags" {
  description = "A map of the tags to use on the resources that are deployed with this module."
  type        = map(string)

  default = {}
}

variable "bootstrap" {
  description = "Parameters for linux bootstrap."
  type        = map(string)

  default = {}
}

variable "custom_data" {
  description = ""
  type        = string

  default = null
}

variable "current_user" {
  description = "Current User running terraform. Will be replaced by a CI variable in the pipeline"
  type        = string
  default     = null
}