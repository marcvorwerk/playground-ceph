#################
### VARIABLES ###
#################

variable "image" {
  type = string
  #default = "Debian 11 Bullseye - Latest"
  default = "Ubuntu 20.04 Focal Fossa - Latest"
  #default = "Ubuntu 22.04 Jammy Jellyfish - Latest"
}
variable "flavor" {
  type = string
  default = "m1.small"
}

variable "vm_az" {
  type = string
  default = "es1"
}

variable "key_pair" {
  type = string
  default = "playground"
  description = "Openstack name of the keypair used for VM creation"
}

variable "osd_hosts" {
  type = number
  default = "5"
}

variable "cloud_init_bastion" {
  default = <<EOF
  #cloud-config
  package_update: true
  package_upgrade: true
  packages:
    - telnet
    - arping

  runcmd:
    - [ sh, -c, "echo Placholder" ]
EOF
}

variable "cloud_init_controller" {
  default = <<EOF
  #cloud-config
  package_update: true
  package_upgrade: true
  packages:
    - cephadm
    - podman

  runcmd:
    - [ sh, -c, "echo Placholder" ]
EOF
}

variable "cloud_init_osd" {
  default = <<EOF
  #cloud-config
  package_update: true
  package_upgrade: true
  packages:
    - cephadm
    - podman
    - lvm2

  runcmd:
    - [ sh, -c, "echo Placholder" ]
EOF
}


############################
### Get PROVIDER Network ###
############################

data "openstack_networking_network_v2" "provider" {
  name = "provider"
}


##########################
### Update ansible.cfg ###
##########################

resource "null_resource" "update_ansible_cfg" {
  triggers = {
    floating_ip = openstack_networking_floatingip_v2.ceph-bastion-fip.address
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "sed 's/@.*\"/@${openstack_networking_floatingip_v2.ceph-bastion-fip.address}\"/' -i ../ansible-cephadm-bootstrap/ansible.cfg"
  }
}

##############
### OUTPUT ###
##############

output "BASTION_FIP" {
  value = "${openstack_networking_floatingip_v2.ceph-bastion-fip.address}"
}
