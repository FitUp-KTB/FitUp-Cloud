variable "ip_names" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "environment" {
  description = "Terraform 워크스페이스 환경 (dev, prod, 등)"
  type        = string
}