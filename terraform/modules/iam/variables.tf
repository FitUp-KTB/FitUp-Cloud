variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "service_account_id" {
  description = "생성할 서비스 계정 ID"
  type        = string
}

variable "display_name" {
  description = "서비스 계정 표시 이름"
  type        = string
}

variable "role" {
  description = "부여할 IAM 역할"
  type        = string
}

variable "key_output_path" {
  description = "서비스 계정 키 파일 저장 경로"
  type        = string
}