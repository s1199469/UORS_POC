# Details voor de provider
provider "esxi" {
  esxi_hostname      = var.esxi_hostname
  esxi_hostport      = var.esxi_hostport
  esxi_hostssl       = var.esxi_hostssl
  esxi_username      = var.esxi_username
  esxi_password      = var.esxi_password
}

# Template for initial configuration bash script
#    template_file is a great way to pass variables to
#    cloud-init
data "template_file" "Default" {
  # template = file("backupserver.tpl")
  template = file(var.vm1_userconfigfile)
  vars = {
    HOSTNAME = var.vm1_hostname
    USER = var.vm1_user
    HELLO = "Hello world!"
    KEY = var.vm_publickey
  }

}
# VM 1
resource "esxi_guest" "Default" {
  guest_name         = var.vm1_hostname
  disk_store         = var.disk_store
  memsize            = var.vm_memsize
  numvcpus           = var.vm_numvcpus
  count              = var.vm1_count

ovf_source = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"

  network_interfaces {
    virtual_network = var.virtual_network
  }
    
  guestinfo = {
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.Default.rendered)
  
  }
}
#
#  Outputs are a great way to output information about your apply.
#


# wegschrijven IP adressen in file
locals {
  ips = [esxi_guest.Default[0].ip_address,esxi_guest.Default[1].ip_address,esxi_guest.Default2[0].ip_address]
}
resource "local_file" "ipaddresses" {
   content = <<-EOT
   [webservers]
   %{ for ip in local.ips }${ip}
   %{ endfor }
   [databaseservers]
   EOT

   filename = "${path.module}/inventory.ini"
}
#  Outputs are a great way to output information about your apply.
#

# output bij gebruik van count kan charmanter, nog niet gevonden 
# hoe dat met een for loop zou kunnen
output "ip1" {
  value = esxi_guest.Default[0].ip_address
}
