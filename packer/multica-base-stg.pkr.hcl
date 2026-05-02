packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "project_id" {
  type    = string
  default = "ai-core-system-bot-stg"
}

variable "region" {
  type    = string
  default = "asia-southeast2"
}

variable "zone" {
  type    = string
  default = "asia-southeast2-a"
}

variable "image_family" {
  type    = string
  default = "multica-base-stg"
}

variable "image_version" {
  type    = string
  default = "v1"
}

source "googlecompute" "multica-base" {
  project_id                   = var.project_id
  region                         = var.region
  zone                             = var.zone
  source_image_family          = "ubuntu-2204-lts"
  source_image_project_id      = ["ubuntu-os-cloud"]
  machine_type                  = "e2-medium"
  instance_name                  = "multica-packer-stg"
  image_name                   = "${var.image_family}-${var.image_version}"
  image_family                  = var.image_family
  image_description            = "Multica base image staging - hardened Ubuntu 22.04 with NTP, monitoring, kernel patching"
  ssh_username                   = "packer"
  preemptible                  = true
  labels = {
    env         = "stg"
    role        = "packer"
    managed_by  = "packer"
    cost_center = "randomops"
  }
  image_labels = {
    env         = "stg"
    managed_by = "packer"
  }
  image_storage_locations = [var.region]
}

build {
  sources = ["source.googlecompute.multica-base"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo Waiting for cloud-init; sleep 5; done",
    ]
    execute_command = "chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do echo Waiting for apt lock; sleep 5; done",
      "apt-get update -qq",
      "apt-get upgrade -y",
      "apt-get install -y curl git ca-certificates gnupg lsb-release python3 python3-pip python3-venv apt-transport-https software-properties-common unzip htop tmux vim unattended-upgrades",
      "apt-get autoremove -y",
      "apt-get clean",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "apt-get install -y systemd-timesyncd",
      "echo '[Time]' > /etc/systemd/timesyncd.conf",
      "echo 'NTP=time.google.com time.cloudflare.com' >> /etc/systemd/timesyncd.conf",
      "echo 'FallbackNTP=ntp.ubuntu.com' >> /etc/systemd/timesyncd.conf",
      "systemctl enable systemd-timesyncd",
      "systemctl start systemd-timesyncd",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config",
      "sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config",
      "sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config",
      "sshd -t",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "bash add-google-cloud-ops-agent-repo.sh --also-install",
      "systemctl enable google-cloud-ops-agent",
      "systemctl start google-cloud-ops-agent",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable' > /etc/apt/sources.list.d/docker.list",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do echo Waiting for apt lock; sleep 5; done",
      "apt-get update -qq",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "systemctl enable docker",
      "systemctl start docker",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "useradd -m -s /bin/bash multica",
      "usermod -aG docker multica",
      "mkdir -p /opt/multica",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }

  provisioner "shell" {
    inline = [
      "apt-get autoremove -y",
      "apt-get clean",
      "find /var/lib/apt/lists -type f -delete",
      "cloud-init clean",
    ]
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} {{ .Path }}"
  }
}
