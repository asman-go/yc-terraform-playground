variable "zone" {
  description = "DC zone"
}

variable "service-account-id" {
  description = "ID SA с ролью container-registry.images.puller"
}

# variable "image-url" {
#   description = "URL образа из Docker Registry"
# }

variable "network-name" {
  description = "VPC network name"
}

variable "subnet-name" {
  description = "VPC subnet name"
}
