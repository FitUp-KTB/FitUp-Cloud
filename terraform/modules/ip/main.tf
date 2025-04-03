resource "google_compute_address" "reserved_ip" {
  for_each = toset(var.ip_names)
  name     = "${each.value}-${var.environment}"
  region   = var.region
}