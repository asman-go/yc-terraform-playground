variable "compose-type" {
  description = "Что разворачиваем"
  type        = string
  default     = "nginx" # nginx | postgres
}

variable "zone" {
  description = "DC zone"
}

variable "service-account-id" {
  description = "ID SA с ролью container-registry.images.puller"
}

variable "security-group-id" {
  description = "Security Group ID"
}

# variable "image-url" {
#   description = "URL образа из Docker Registry"
# }

# variable "network-name" {
#   description = "VPC network name"
# }

variable "subnet-name" {
  description = "VPC subnet name"
}

variable "domain-zone" {
  description = "Domain zone"
}

variable "ssh-public-key-path" {
  description = "SSH key host path"
}
