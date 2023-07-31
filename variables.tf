variable "location" {
  type    = string
  default = "North Europe"
}

variable "tags" {
  type = map

 default = {
    LOB         = "NIW"
    environment = "PROD"
    dc          = "ID"
	scope       = "NETWORKS"
	managed-by  = "Terraform"
          }
}


