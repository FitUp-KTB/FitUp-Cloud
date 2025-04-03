variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "credentials" {
  description = "Path to GCP service account key JSON file"
  type        = string
}

variable "region" {
  description = "리소스를 생성할 GCP 리전"
  type        = string
}

variable "zone" {
  description = "컴퓨트 인스턴스를 생성할 GCP 존"
  type        = string
}

variable "shared_service_account_email" {
  description = "Shared VM에서 생성된 서비스 계정 이메일"
  type        = string
}