resource "google_service_account" "shared_vm" {
  account_id   = var.service_account_id
  display_name = var.display_name
}

resource "google_project_iam_member" "shared_vm_editor" {
  project = var.project_id
  role    = var.role
  member  = "serviceAccount:${google_service_account.shared_vm.email}"
}

resource "google_service_account_key" "shared_vm_key" {
  service_account_id = google_service_account.shared_vm.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "local_file" "shared_vm_key_file" {
  content  = google_service_account_key.shared_vm_key.private_key
  filename = var.key_output_path
}
