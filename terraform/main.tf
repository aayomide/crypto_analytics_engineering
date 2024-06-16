# =========================================================================================================
# Create Virtual machine (incl. SSH and GC CLI authentication, and initial installation of some libraries)
# =========================================================================================================

resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240519"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  service_account {
    email = google_service_account.cryptolytics-sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.gce_ssh_user
      host        = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
      private_key = file(var.ssh_priv_key_file)
    }
    inline = [
      "git clone https://github.com/aayomide/crypto_analytics_engineering.git",
      "sudo apt-get install wget",
      "wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh",
      "bash Anaconda3-2022.10-Linux-x86_64.sh -b -p /home/aayomide/anaconda3",
      "rm Anaconda3-2022.10-Linux-x86_64.sh",
      "export PATH=/home/aayomide/anaconda3/bin:$PATH"
    ]
  }
}