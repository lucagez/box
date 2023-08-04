terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
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
  image  = "ubuntu-22-04-x64"
  name   = var.name
  region = var.region
  size   = var.size

  tags     = ["${var.name}-box"]
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  user_data = <<EOF
#cloud-config
packages:
- git
- python3
- python3-pip
- ansible
runcmd:
- touch /root/cloud-init-started
- echo "alias wait_cloud_init='tail -f /var/log/cloud-init-output.log'" >> ~/.bashrc
- git clone https://github.com/lucagez/box /root/box
- mkdir -p /root/.config/nvim
- cp /root/box/init.lua /root/.config/nvim/
- cp /root/box/lazy-lock.json /root/.config/nvim/
- cp /root/box/.tmux.conf /root/
- cp /root/box/.zshrc /root/
- cp go-install.sh /root/
- cp /root/ssh_init /usr/local/bin/
- ansible-playbook -i localhost, /root/box/local.playbook.yml -vvvv
- echo "Done 📦"
EOF
}

output "droplet_output" {
  value = digitalocean_droplet.web.ipv4_address
}
