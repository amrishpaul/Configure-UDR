# centos v6.5

Terraform module to build CentOS VM in Azure using **Azure RM Terraform Provider 2.x only**.

If you're still using Azure RM Terraform provider 1.x, stick to centos module v2.5.

## Module Defaults

- OS Image: `OpenLogic CentOS 7.9.2020111900`
- Admin account: `nod_admin/NODpassword123!`
- Password Authentication: `true`
- OS Disk type: `vm_disk_type: StandardSSD_LRS`
- Data Disk for `/var/log` partition
  - Default disk size for `/var/log`: `20GB` ()
  - set `enable_datadisk_varlog` to `false` to disable `/var/log` data disk creation
- Data disk default settings:
  - Create option: `Empty`
  - Caching requirements for this Data Disk: `ReadWrite`
- Network interfaces:
  - Accelerated Networking: `false`
  - IP forwarding: `false`
- Puppet Bootstrap: `true`
- Image bootstrap URL: `http://linux-yum/NOD/Azure/bootstrap/centos7/image_bootstrap.sh`
- Platform: `nvod`
- Delete OS and Data Disks on VM destruction: `true`
- No Availability Set. Provide `availability_set_id` otherwise
- `dns_domains`: `<site>[].<tier>].nod.nuance.com [<tier>.]nod.nuance.com`. Site and Tier auto-detected based on VM Name

## Module Mandatory Parameters

- `resource_group`: Target resource group where all dependents resources will be created
- There are 2 ways to configure the NIC(s)
  - To only assign a single private IP address:
    ```yaml
    ip_address = "<ip-address>"
    subnet_id  = azurerm_subnet.my_subnet.id
    # nics = [] <= should be removed
    ```
  - To create multiple NICs, assign one or more private IP addresses, a public IP address or tweak NIC settings (IP forwarding, network acceleration), you need to use the `nics` attribute instead of `ip_address` and `subnet_id`
    ```yaml
    nics = [ { ip_address = [ { private_ip = "<private-ip-address>", public_ip = azurerm_public_ip.my_public_ip.id } ]
               subnet_id = azurerm_subnet.another_subnet.id
               settings  = {} } ]
    # ip_address = "<ip-address>" <= should be removed
    # subnet_id  = azurerm_subnet.my_subnet.id <= should be removed
    ```
  - To enable IP forwarding and/or accelerated networking, pass `ip_forwarding = true` and/or `accelerated_networking = true in the NIC `settings` map.
- `vm_name`: Name of the virtual machine
- `vm_size`: Size of the VM. See `az vm list-sizes -l <azure-region>` to see what VM size the region supports.

## Optional Parameters

- `admin`: map that contains user `name`, `password` and `public_key` to connect to the VM
- `data_disks`: list of Data Disks
- `enable_datadisk_varlog`: "Whether or not including a datadisk for /var/log partition."
- `varlog_disk_size_gb`: Size of /var/log datadisk if enable_datadisk_varlog is set to true.
- `os`: map with `publisher`, `offer`, `sku`, `version` keys that points to a Market Place image
- `image_id`: Image ID to use if not using a Market Place image (not recommended)
- `availability_set_id`: Availability Set ID to assign the VM to
- `os_disk_size_gb`: Size of OS data disk. Use image size if not set.
- `vm_settings`: map to override VM default settings
  - Managed Service Identity (MSI): `msi_enabled`. Default: `false`
  - Puppet Bootstrap: `bootstrap_enabled`. Default: `true`
  - Accelerated Networking: `accelerated_networking`. Default: `false`
  - Storage account for Boot diagnostics: `boot_diagnostics`. Default: `true`
  - Linux Diagnostics Extension (LAD 3.0): `linux_diagnostics`. Default: `false`
  - SSH Password authentication: `password_authentication`. Default: `true`
- `sa_diagnostics`: Storage Account to store Boot Diagnostics and Linux Diagnostics
- `plan`: Image Billing plan
- `tags`: Tags to apply on all resources created by the module
- `bootstrap`: Path to a custom bootstrap script
- `custom_data`: Custom Data to provide to cloud-init (need to be base64-encoded)

## Module limitations

- You can't use different versions of a terraform provider, so if you want to use centos module 4.0+ version, **ALL** your code needs to support Azure RM TF Provider 2.x!
- VM Name **must** respect the naming convention in order to use DNS domains auto-detection. Otherwise you **need** to specify `dns_domains`.
  - 1st letter: `n` or `s` (only production and stage environments supported for now)
  - 3rd and 4th letters: site acronym used in nodes [registry](https://vip-gitlab.staging.nod.nuance.com/puppet/nodes/tree/master/registry)
  - Example: `nvulmid6400`

## Example

```terraform
module "<VM Name>" {
  source              = "git::ssh://git@vip-gitlab.staging.nod.nuance.com/terraform/terraform-modules/centos.git?ref=v6.4"
  # Resource Group where to build the VM. It will be deployed in the same resource group location
  resource_group      = azurerm_resource_group.my_resource_group

  # Single NIC (nics attribute should be removed)
  ip_address          = "<ip-address>"
  subnet_id           = azurerm_subnet.my_subnet.id
  # Multiple NICs or IP config (ip_address and subnet_id attributes should be removed)
  ## example: 1 NIC with private and public IPs, 1 NIC with private IP
  nics                = [ { ip_address = [ { private_ip = "<private-ip-address>", public_ip = azurerm_public_ip.my_public_ip.id }
                            subnet_id = azurerm_subnet.my_subnet.id
                            settings = {} },
                          { ip_address = [ { private_ip = "<private-ip-address>" } ]
                            subnet_id = azurerm_subnet.my_subnet.id
                            settings = {} } ]

  # (Optional) Need to create availability set beforehand
  availability_set_id = azurem_availability_set.my_avs.id

  vm_name             = "<VM Name>"
  vm_size             = "<VM Size>"
  vm_disk_type        = "Standard_LRS"

  # [Optional] List of extra disks.
  data_disks          = [{ disk_type = "Standard_LRS", size = 50 }, { disk_type = "Premium_LRS", create_option = "From", image_id = "<image Id>" }]
  # [Optional] Boot and Linux Guest VM Diagnostics Storage Account
  sa_diagnostics      = azurerm_storage_account.bootdiag_sa
  # [Optional] Availability Set ID
  availability_set_id = azurerm_availability_set.my_avs.id

  # Tags to apply to all resources created by this module
  tags                = {
    LOB         = "<LOB>"
    environment = "<Environment>"
  }
}
```
P.S.: Don't forget to replace the placeholders between `<>` and the terraform resource references accordingly.

In case you need to stick to a earlier module version, just change to `?ref=v2.4.0` in the `source` attribute (if v2.4.0 is the version you want to stick to).

## Outputs

* `id`: Azure Resource ID of the Virtual Machine
* `name`: Virtual Machine Name
* `virtual_machine_id`: A 128-bit identifier which uniquely identifies this Virtual Machine
* `primary_nic`: Primary NIC
* `nics`: list of NICs
* `identity`: list of Machine System Identities and User Managed Identities used by the VM
* `os`: Operating System of the VM
* `vm_settings`: Settings used for the provisioning of the VM

# TODO

- [x] add username automatically to deployed objects
- [x] add managedby: <gitlab-ent> to all deployed devices
- [ ] Create Availability Sets automatically
- [ ] Support Log Analytics agent instead of LAD
- [ ] add scheduler to lab to turn off vm in lab devicees by default
