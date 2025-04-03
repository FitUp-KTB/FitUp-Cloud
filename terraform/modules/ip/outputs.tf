output "ip_addresses" {
  value = { for ip in google_compute_address.reserved_ip : ip.name => ip.address }
}