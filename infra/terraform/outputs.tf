output "server_ips" {
  description = "IPv4 addresses of the LXD containers"
  value = {
    for name, c in lxd_instance.servers :
    name => c.ipv4_address
  }
}

