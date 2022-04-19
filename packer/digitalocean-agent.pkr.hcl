packer {
  required_plugins {
    digitalocean = {
      version = "=1.0.3"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

source "digitalocean" "pmm-ovf" {
  droplet_name = "pmm-ovf"
  image        = "centos-7-x64"
  region       = "ams3"
  size         = "s-2vcpu-4gb-intel"
  ssh_username = "root"
  snapshot_name = "pmm-agent"
}

build {
  name    = "jenkins-farm"
  sources = ["source.digitalocean.pmm-ovf"]

  provisioner "ansible" {
    playbook_file = "./ansible/agent.yml"
  }
}
