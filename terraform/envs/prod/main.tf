provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# ---------------------------
# Subnet (Public / Private)
# ---------------------------
resource "google_compute_subnetwork" "prod_public_subnet" {
  name                     = "subnet-prod-public"
  ip_cidr_range            = "10.20.0.0/24"
  region                   = var.region
  network                  = var.shared_vpc_id
}

resource "google_compute_subnetwork" "prod_private_subnet" {
  name                     = "subnet-prod-private"
  ip_cidr_range            = "10.20.1.0/24"
  region                   = var.region
  network                  = var.shared_vpc_id
  private_ip_google_access = true
}

# ---------------------------
# Static IP for public NginX
# ---------------------------
resource "google_compute_address" "prod_ip" {
  name   = "prod-static-ip"
  region = var.region
}

# ---------------------------
# Public NginX + Frontend
# ---------------------------
module "prod_frontend_vm" {
  source                = "../../modules/compute"
  name                  = "prod-frontend-compute"
  instance_name         = "prod-frontend"
  machine_type          = "e2-micro"
  zone                  = var.zone
  tags                  = ["develop"]
  image                 = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  nat_ip                = google_compute_address.prod_ip.address
  network_id            = var.shared_vpc_id
  subnetwork_id         = google_compute_subnetwork.prod_public_subnet.id
  boot_disk_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size        = 20
  boot_disk_type        = "pd-balanced"
  service_account_email = var.shared_service_account_email
}

# ---------------------------
# Private Backend VM
# ---------------------------
module "prod_backend_vm" {
  source                = "../../modules/compute"
  name                  = "prod-backend-compute"
  instance_name         = "prod-backend"
  machine_type          = "e2-small"
  zone                  = var.zone
  tags                  = ["backend"]
  image                 = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  nat_ip                = null
  network_id            = var.shared_vpc_id
  subnetwork_id         = google_compute_subnetwork.prod_private_subnet.id
  boot_disk_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size        = 20
  boot_disk_type        = "pd-balanced"
  service_account_email = var.shared_service_account_email
}

# ---------------------------
# Private AI VM
# ---------------------------
module "prod_ai_vm" {
  source                = "../../modules/compute"
  name                  = "prod-ai-compute"
  instance_name         = "prod-ai"
  machine_type          = "e2-small"
  zone                  = var.zone
  tags                  = ["ai"]
  image                 = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  nat_ip                = null
  network_id            = var.shared_vpc_id
  subnetwork_id         = google_compute_subnetwork.prod_private_subnet.id
  boot_disk_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size        = 20
  boot_disk_type        = "pd-balanced"
  service_account_email = var.shared_service_account_email
}

# ---------------------------
# Private MySQL DB VM
# ---------------------------
module "prod_mysql_vm" {
  source                = "../../modules/compute"
  name                  = "prod-mysql-compute"
  instance_name         = "prod-mysql"
  machine_type          = "e2-small"
  zone                  = var.zone
  tags                  = ["mysql"]
  image                 = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  nat_ip                = null
  network_id            = var.shared_vpc_id
  subnetwork_id         = google_compute_subnetwork.prod_private_subnet.id
  boot_disk_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  boot_disk_size        = 20
  boot_disk_type        = "pd-balanced"
  service_account_email = var.shared_service_account_email
}
