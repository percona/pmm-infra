packer {
  required_plugins {
    digitalocean = {
      version = "=1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

source "digitalocean" "pmm-ovf" {
  droplet_name = "pmm-ovf"
  image        = "centos-7-x64"
  region       = "ams3"
  size         = "s-4vcpu-8gb-intel"
  ssh_username = "root"
  snapshot_name = "pmm-agent"
}

build {
  name    = "jenkins-farm"
  sources = ["source.digitalocean.pmm-ovf"]

  provisioner "ansible" {
    extra_arguments = [ "-v" ]
    max_retries = 1
    playbook_file = "./ansible/agent.yml"
  }
}
