locals {
  # Names of your two servers
  instance_ips = {
    "server-01" = "10.79.225.111"
    "server-02" = "10.79.225.112"
  }
  # Path to the public key matching ~/.config/ssh/share_key
  ssh_pubkey_path = pathexpand("../secret_files/shared_key.pub")

  # Read the public key and trim newline
  ssh_pubkey = trimspace(file(local.ssh_pubkey_path))

  # Render cloud-init user-data once, reuse for all instances
  cloud_init_user_data = templatefile("${path.module}/cloud-init.yaml", {
    ssh_authorized_key = local.ssh_pubkey
  })
}

resource "lxd_instance" "servers" {

  for_each = local.instance_ips
  name      = each.key
  image     = "ubuntu:24.04"     # Ubuntu 24 LTS image (from ubuntu image server)
  ephemeral = false
  profiles  = ["default"]

  # Make sure we wait until network is ready before Terraform finishes
  wait_for_network = true

  # Pass cloud-init into LXD; cloud-init runs on first boot only :contentReference[oaicite:2]{index=2}
  config = {
    "user.user-data" = local.cloud_init_user_data
  }

  device  {
    name = "eth0"
    type = "nic"
    properties = {
      network        = "lxdbr0"              # your LXD bridge
      "ipv4.address" = each.value            # the IP from local.instance_ips
    }
  }
  # Example resource limits (optional – adjust to your needs)
  limits = {
    cpu    = 2
    memory = "2GB"
  }
}

