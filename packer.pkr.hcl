packer {
	required_plugins {
		docker = {
			source  = "github.com/hashicorp/docker"
			version = "~> 1"
		}
		ansible = {
			source  = "github.com/hashicorp/ansible"
			version = "~> 1"
		}
	}
}

variable "ansible_host" {
	default = "default"
}

variable "ansible_connection" {
	default = "docker"
}

source "docker" "ubuntu_box" {
	image  = "ubuntu:22.04"
	commit = true
	changes = [
		"ENV EDITOR nvim",
		"EXPOSE 22",
		"ENTRYPOINT /usr/sbin/sshd -D"
	]
	run_command = ["-d", "-i", "-t", "--name", var.ansible_host, "{{.Image}}", "/bin/bash"]
}

# TODO: Add qemu and parallels builders

build {
	sources = [
		"source.docker.ubuntu_box"
	]

	provisioner "shell" {
		inline = [
			"mkdir -p /root/.config/nvim",
		]
	}

	provisioner "file" {
		sources = [
			".tmux.conf",
			".zshrc",
			"go-install.sh",
		]
		destination = "/root/"
	}

	provisioner "file" {
		sources = [
			"init.lua",
			"lazy-lock.json",
		]
		destination = "/root/.config/nvim/"
	}

	provisioner "file" {
		source = "ssh_init"
		destination = "/usr/local/bin/"
	}

	provisioner "shell" {
		inline = [
			"apt-get update",
			"apt-get install -y python3"
		]
	}

	provisioner "ansible" {
		playbook_file = "./playbook.yml"
		extra_arguments = [
			"--extra-vars",
			"ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection} ansible_user=root"
		]
	}
}
