terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.9"
    }
  }

  required_version = ">= 1.5.0"
}

provider "lxd" {
  # For local LXD over Unix socket this is usually enough.
  # If you use a remote LXD server, you’d add remote config here.
  generate_client_certificates = true
  accept_remote_certificate    = true
}

