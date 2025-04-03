variable "name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnetwork to create"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range of the subnetwork (e.g., 10.0.0.0/24)"
  type        = string
}

variable "region" {
  description = "Region where the VPC and subnet will be created"
  type        = string
}
