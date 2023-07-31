variable "location" {
  type    = string
  default = "northeurope"
}

variable "tags" {
  type = map

  default = {
    LOB         = "SHARED"
    environment = "ID PROD"
  }
}

variable "dnssearchlist" {
  type    = list
  default = ["id.nod.nuance.com", "nod.nuance.com"]
}
