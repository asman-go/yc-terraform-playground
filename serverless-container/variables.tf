variable "service-account-id" {
  description = "ID SA с ролью container-registry.images.puller"
}

variable "image-url" {
  description = "URL образа из Docker Registry"
}

variable "network-name" {
  description = "VPC network name"
}
