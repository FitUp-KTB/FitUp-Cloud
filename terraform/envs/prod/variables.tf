variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "credentials" {
  description = "Path to GCP service account key JSON file"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "zone" {
  description = "GCP 존"
  type        = string
}

variable "shared_vpc_id" {
  description = "Shared VPC ID from shared output"
  type        = string
}

variable "shared_service_account_email" {
  description = "Shared 서비스 계정 이메일"
  type        = string
}