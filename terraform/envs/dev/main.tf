provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_subnetwork" "dev_subnet" {
  name          = "subnet-dev"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = var.shared_vpc_id
}

resource "google_compute_subnetwork" "dev_private_subnet" {
  name          = "subnet-dev-private"
  ip_cidr_range = "10.10.1.0/24"
  region        = var.region
  network       = var.shared_vpc_id
  private_ip_google_access = true
}

resource "google_compute_address" "dev_ip" {
  name    = "dev-static-ip"
  region  = var.region
  address = "34.47.120.29"

  lifecycle {
    prevent_destroy = true
  }
}

module "dev_vm" {
  source                  = "../../modules/compute"
  name                    = "dev-compute"
  instance_name           = "dev"
  machine_type            = "e2-small"
  zone                    = var.zone
  tags                    = ["develop"]
  image                   = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  nat_ip                  = google_compute_address.dev_ip.address
  network_id              = var.shared_vpc_id
  subnetwork_id           = google_compute_subnetwork.dev_subnet.id
  boot_disk_image         = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size          = 30
  boot_disk_type          = "pd-balanced"
  service_account_email = var.shared_service_account_email
}

module "dev_mysql_vm" {
  source                  = "../../modules/compute"
  name                    = "dev-mysql-compute"
  instance_name           = "dev-mysql"
  machine_type            = "e2-small"
  zone                    = var.zone
  tags                    = ["mysql"]
  image                   = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  nat_ip                  = null
  network_id              = var.shared_vpc_id
  subnetwork_id           = google_compute_subnetwork.dev_private_subnet.id
  boot_disk_image         = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size          = 20
  boot_disk_type          = "pd-balanced"
  service_account_email   = var.shared_service_account_email
}