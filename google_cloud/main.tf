resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = "vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "vpc-subnet"
  ip_cidr_range = "10.123.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.vpc_subnet.name
    access_config {}
  }
}

resource "google_compute_firewall" "firewall" {
  name    = "firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_router" "default_router" {
  name    = "default-router"
  network = google_compute_network.vpc_network.name
  project = var.project
  region  = var.region
}

resource "google_compute_router_nat" "router_nat" {
  name    = "router-nat"
  router  = google_compute_router.default_router.name
  project = var.project
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}