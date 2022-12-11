packer {
  required_plugins {
    amazon = {
      version = "=1.1.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "agent" {
  ami_name              = "Docker Agent v2"
  instance_type         = "t3.xlarge"
  force_deregister      = true
  force_delete_snapshot = true
  region                = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "*amzn2-ami-hvm-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
  tags = {
    Name            = "Jenkins Agent x86_64"
    iit-billing-tag = "pmm-worker"
  }
  run_tags = {
    iit-billing-tag = "pmm-worker"
  }
  run_volume_tags = {
    iit-billing-tag = "pmm-worker"
  }
  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }
  vpc_filter {
    filters = {
      "tag:Name" : "jenkins-pmm-amzn2"
    }
  }
  subnet_filter {
    filters = {
      "tag:Name" : "jenkins-pmm-amzn2-B"
    }
    random = true
  }
}

source "amazon-ebs" "arm-agent" {
  ami_name              = "Docker Agent ARM v2"
  instance_type         = "t4g.xlarge"
  force_deregister      = true
  force_delete_snapshot = true
  region                = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "*amzn2-ami-hvm-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "arm64"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
  tags = {
    Name            = "Jenkins Agent arm64"
    iit-billing-tag = "pmm-worker"
  }
  run_tags = {
    iit-billing-tag = "pmm-worker",
  }
  run_volume_tags = {
    iit-billing-tag = "pmm-worker"
  }
  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }
  vpc_filter {
    filters = {
      "tag:Name" : "jenkins-pmm-amzn2"
    }
  }
  subnet_filter {
    filters = {
      "tag:Name" : "jenkins-pmm-amzn2-B"
    }
    random = true
  }
}

build {
  name = "jenkins-farm"
  sources = [
    "source.amazon-ebs.agent",
    "source.amazon-ebs.arm-agent"
  ]
  provisioner "ansible" {
    use_proxy              = false
    user                   = "ec2-user"
    ansible_ssh_extra_args = ["-o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o ForwardAgent=yes -o UserKnownHostsFile=/dev/null"]
    extra_arguments        = ["-v"]
    playbook_file          = "./ansible/agent.yml"
  }
}
