variable "network_name" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  type = list(object({
    name          = string,
    ip_cidr_range = string
  }))
}

variable "environment" {
  description = "Terraform 워크스페이스 환경 (dev, prod, 등)"
  type        = string
}