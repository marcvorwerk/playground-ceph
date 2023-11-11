#################################
### Create Network and Subnet ###
#################################

resource "openstack_networking_network_v2" "ceph-network" {
  name = "ceph-network"
}

resource "openstack_networking_subnet_v2" "ceph-subnet" {
  name            = "ceph-subnet"
  network_id      = openstack_networking_network_v2.ceph-network.id
  ip_version      = 4
  cidr            = "10.0.0.0/24"
  depends_on = [
    openstack_networking_network_v2.ceph-network
  ]
}


#####################
### Create Router ###
#####################

resource "openstack_networking_router_v2" "ceph-router" {
  name                = "ceph-router"
  admin_state_up      = "true"
  external_network_id = data.openstack_networking_network_v2.provider.id
  depends_on = [
    openstack_networking_subnet_v2.ceph-subnet
  ]
}

resource "openstack_networking_router_interface_v2" "port-ceph-router" {
  router_id  = openstack_networking_router_v2.ceph-router.id
  subnet_id  = openstack_networking_subnet_v2.ceph-subnet.id
  depends_on = [
    openstack_networking_router_v2.ceph-router
  ]
}
