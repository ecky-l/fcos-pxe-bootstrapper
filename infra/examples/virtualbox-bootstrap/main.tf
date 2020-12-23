module "vb_snippets" {
  source = "git::https://github.com/ecky-l/fcos-ignition-snippets.git//modules/ignition-snippets"

  user_authorized_keys = {
    befruchter = [
      file("~/.ssh/id_rsa.pub")
    ]
  }

  networks = {
    befruchter = {
      "enp0s8" = {
        "ipv4" = {
          "method" = "manual"
          "address1" = "10.10.0.1/16"
          "dns" = "10.10.0.1;"
          "dns-search" = "local.vlan;"
        }
      }
      "enp0s9" = {
        "ipv4" = {
          "method" = "manual"
          "address1" = "192.168.56.19/24"
        }
      }
    }
  }

  root_partition_size_gib = {
    befruchter = 8
  }
}

module "virtualbox-bootstrapper" {
  source = "../../../modules/fcos-pxe-bootstrapper"
  host_name = "befruchter.home.el"
  public_dns = "192.168.2.10"

  dhcpd_config = {
    interface = "enp0s8"
    domain_name = "local.vlan"
    dns = "10.10.0.1"
    net = "10.10.0.0"
    netmask = "255.255.0.0"
    range_lower = "10.10.1.0"
    range_upper = "10.10.255.254"
    broadcast = "10.10.255.255"
  }
  snippets = [
    module.vb_snippets.user_snippets.befruchter.content,
    module.vb_snippets.storage_snippets.befruchter.content,
    module.vb_snippets.network_snippets.befruchter.content,
  ]
}

resource "local_file" "bootstrapper-ignition" {
  content = module.virtualbox-bootstrapper.bootstrapper-ignition
  filename = "output/bootstrapper.ign"
}