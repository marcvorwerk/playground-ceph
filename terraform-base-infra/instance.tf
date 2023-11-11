########################
### Create Instances ###
########################

resource "openstack_compute_instance_v2" "ceph-bastion-instance" {
  name              = "ceph-bastion-instance"
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = var.key_pair
  availability_zone = var.vm_az
  tags              = ["tf-ceph-bastion"]
  user_data         = var.cloud_init_bastion
  security_groups   = [
    openstack_networking_secgroup_v2.ceph-secgrp.name,
  ]
  network {
    uuid = openstack_networking_network_v2.ceph-network.id
  }
  depends_on = [
    openstack_networking_subnet_v2.ceph-subnet,
    openstack_networking_secgroup_v2.ceph-secgrp
  ]
}

resource "openstack_compute_instance_v2" "ceph-controller-instance" {
  name              = "ceph-controller-instance-${count.index}"
  count             = 3
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = var.key_pair
  availability_zone = var.vm_az
  tags              = ["tf-ceph-controller"]
  user_data         = var.cloud_init_controller
  security_groups   = [
    openstack_networking_secgroup_v2.ceph-secgrp.name,
  ]
  network {
    uuid = openstack_networking_network_v2.ceph-network.id
  }
  depends_on = [
    openstack_networking_subnet_v2.ceph-subnet,
    openstack_networking_secgroup_v2.ceph-secgrp
  ]
}

resource "openstack_compute_instance_v2" "ceph-osd-instance" {
  name              = "ceph-osd-instance-${count.index}"
  count             = var.osd_hosts
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = var.key_pair
  availability_zone = var.vm_az
  tags              = ["tf-ceph-osd"]
  user_data         = var.cloud_init_osd
  security_groups   = [
    openstack_networking_secgroup_v2.ceph-secgrp.name,
  ]
  network {
    uuid = openstack_networking_network_v2.ceph-network.id
  }
  depends_on = [
    openstack_networking_subnet_v2.ceph-subnet,
    openstack_networking_secgroup_v2.ceph-secgrp
  ]
}


#################################
### Create and attach Volumes ###
#################################

resource "openstack_blockstorage_volume_v3" "ceph-osd-volume" {
  name  = "ceph-osd-volume-${count.index}"
  count = var.osd_hosts * 3
  availability_zone = var.vm_az
  size  = 10
}

resource "openstack_compute_volume_attach_v2" "ceph-volume-attach" {
  #instance_id = element(openstack_compute_instance_v2.ceph-osd-instance.*.id, count.index / 3)
  instance_id = openstack_compute_instance_v2.ceph-osd-instance[count.index % var.osd_hosts].id
  count       = var.osd_hosts * 3
  volume_id   = openstack_blockstorage_volume_v3.ceph-osd-volume[count.index].id
}


#############################
### Create and attach FIP ###
#############################

resource "openstack_networking_floatingip_v2" "ceph-bastion-fip" {
  pool = "provider"
  depends_on = [
    openstack_networking_subnet_v2.ceph-subnet,
    openstack_networking_router_v2.ceph-router
  ]
}

resource "openstack_compute_floatingip_associate_v2" "ceph-bastion-fip-accociate" {
  floating_ip = "${openstack_networking_floatingip_v2.ceph-bastion-fip.address}"
  instance_id = "${openstack_compute_instance_v2.ceph-bastion-instance.id}"
  depends_on = [
    openstack_compute_instance_v2.ceph-bastion-instance,
    openstack_networking_floatingip_v2.ceph-bastion-fip
  ]
}
