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
  snapshot_name = "pmm-ovf-builder"
}

build {
  provisioner "shell" {
      expect_disconnect = true
      inline = [
          "yum upgrade -y",
          "yum -y install java-1.8.0-openjdk git kernel-devel kernel-headers wget gcc make perl",
          "wget https://www.virtualbox.org/download/oracle_vbox.asc -O /tmp/oracle_vbox.asc",
          "rpm --import /tmp/oracle_vbox.asc",
          "wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo",
          "yum install -y VirtualBox-6.1",
          "systemctl enable vboxdrv",
          "reboot",
          "/sbin/vboxconfig"
      ]
  }

  sources = ["source.digitalocean.pmm-ovf"]
}
