terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
	description = "Digital Ocean API token"
}

variable "name" {
	description = "📦 Name for current box"
}

variable "region" {
	description = "The region where the droplet will be created"
	default     = "fra1"
}

variable "size" {
	description = "The size of the droplet (resources)"
	default     = "s-2vcpu-4gb"
}

provider "digitalocean" {
  	token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "Local SSH Key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "web" {
    image = "ubuntu-22-04-x64"
    name = var.name
    region = var.region
    size = var.size

    tags = ["${var.name}-box"]
	ssh_keys = [digitalocean_ssh_key.default.fingerprint]

    user_data = <<EOF
    #cloud-config
    packages:
        - git
        - python3
        - python3-pip
    runcmd:
		- python3 -m pip install --user ansible
		- export PATH="/root/.local/bin:$PATH"
		- git clone https://github.com/lucagez/box
		- cd box
		- ansible-playbook -i localhost, local.playbook.yml -vvvv
    EOF
}

output "droplet_output" {
	value = digitalocean_droplet.web.ipv4_address
}
