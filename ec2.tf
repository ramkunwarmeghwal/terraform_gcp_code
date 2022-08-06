provider "google" {
  project = "lq-learn"
  region  = "asia-south1"
}


resource "google_compute_address" "test-static-ip-address" {
  count = 2
  name = "ip${count.index}"
}


resource "google_compute_firewall" "firewall" {
  name    = "gritfy-firewall-externalssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["ssh"]
}



resource "google_compute_instance" "default" {
  count = 4
  name  = "server${count.index}"
  machine_type  = "custom-1-1024"
  //machine_type  = "n1-standard-1"
  zone      =    "asia-south1-a"
  tags          = ["ssh","http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-arm64-v20220712"     
    }
  }


    metadata_startup_script = "sudo add-apt-repository ppa:certbot/certbot;  sudo apt install python2; curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py;  sudo python2 get-pip.py;  python2 -m pip install requests; python2 -m pip install beautifulsoup4; python2 -m pip install pymongo; python2 -m pip install boto; python2 -m pip install html5lib; python2 -m pip install Pillow; sudo apt install tesseract-ocr; sudo apt install libtesseract-dev"
        
  

  depends_on = [ google_compute_firewall.firewall]



network_interface {
    network = "default"
    access_config {
       nat_ip = google_compute_address.static.address
      // Ephemeral IP
    }
  }
}