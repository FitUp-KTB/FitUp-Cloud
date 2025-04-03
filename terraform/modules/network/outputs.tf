output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_ids" {
  value = { for name, subnet in google_compute_subnetwork.subnet : name => subnet.self_link }
}