provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "iam_shared_vm" {
  source             = "../../modules/iam"
  project_id         = var.project_id
  service_account_id = "shared-vm"
  display_name       = "Service account for shared VM (VPN + Monitoring)"
  role               = "roles/editor"
  key_output_path    = "${path.module}/shared-vm-sa-key.json"
}

module "vpc" {
  source       = "../../modules/vpc"
  name         = "fitup-vpc"
  subnet_name  = "subnet-shared"
  subnet_cidr  = "10.0.0.0/24"
  region       = var.region
}

resource "google_compute_address" "shared_ip" {
  name    = "shared-static-ip"
  region  = var.region
  address = "34.22.98.89"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_firewall" "firewall_allow_ssh" {
  name               = "allow-ssh"
  network            = module.vpc.network_id
  direction          = "INGRESS"
  priority           = 1000
  source_ranges      = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

module "firewall_allow_vpn" {
  source        = "../../modules/firewall"
  firewall_name = "allow-vpn-udp-51820"
  network_id    = module.vpc.network_id
  description   = "Allow WireGuard VPN UDP traffic"

  allow = [
    {
      protocol = "udp"
      ports    = ["51820"]
    }
  ]

  source_ranges = ["0.0.0.0/0"]
  source_tags   = []
  target_tags   = ["vpn-server"]
}

resource "google_compute_firewall" "allow_develop_ports" {
  name    = "allow-develop-ports"
  network = module.vpc.network_id

  direction = "INGRESS"
  priority  = 1000
  disabled  = false
  description = "Allow inbound traffic on ports 80, 443, 3000, 8000, 8080 for instances with develop tag"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000", "8000", "8080"]
  }

  target_tags = ["develop"]

  source_ranges = ["0.0.0.0/0"]

  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_firewall" "allow_backend_port" {
  name          = "allow-backend-8080"
  network       = module.vpc.network_id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  target_tags = ["backend"]

  description = "Allow inbound HTTP traffic to backend (8080)"

  lifecycle {
    ignore_changes = [description]
  }
}

resource "google_compute_firewall" "allow_ai_port" {
  name          = "allow-ai-8000"
  network       = module.vpc.network_id
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  target_tags = ["ai"]

  description = "Allow inbound HTTP traffic to AI service (8000)"

  lifecycle {
    ignore_changes = [description]
  }
}

module "firewall_allow_mysql" {
  source        = "../../modules/firewall"
  firewall_name = "allow-mysql-3306"
  network_id    = module.vpc.network_id
  description   = "Allow MySQL access from dev instances"

  allow = [
    {
      protocol = "tcp"
      ports    = ["3306"]
    }
  ]

  source_ranges = ["0.0.0.0/0"]
  source_tags   = []
  target_tags   = ["mysql"]
}

resource "google_compute_router" "shared_nat_router" {
  name    = "shared-nat-router"
  network = module.vpc.network_id
  region  = var.region
}

resource "google_compute_router_nat" "shared_nat" {
  name                               = "shared-nat-config"
  router                             = google_compute_router.shared_nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = var.dev_private_subnet_name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = var.prod_private_subnet_name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}


module "shared_vm" {
  source                = "../../modules/compute"
  name                  = "shared-compute"
  instance_name         = "shared"
  machine_type          = "e2-micro"
  zone                  = var.zone
  tags                  = ["vpn-server", "monitoring"]
  image                 = "ubuntu-os-cloud/ubuntu-2204-lts"

  nat_ip                = google_compute_address.shared_ip.address
  network_id            = module.vpc.network_id
  subnetwork_id         = module.vpc.subnet_id
  boot_disk_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size        = 30
  boot_disk_type        = "pd-balanced"
  service_account_email   = module.iam_shared_vm.service_account_email
}