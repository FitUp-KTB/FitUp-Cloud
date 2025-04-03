output "service_account_email" {
  description = "생성된 서비스 계정 이메일"
  value       = google_service_account.shared_vm.email
}

output "service_account_key_file" {
  description = "생성된 서비스 계정 키 파일 경로"
  value       = local_file.shared_vm_key_file.filename
}