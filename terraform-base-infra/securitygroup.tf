########################################
### Create Security Groups and Rules ###
########################################

# Create ceph-secgrp
resource "openstack_networking_secgroup_v2" "ceph-secgrp" {
  name        = "ceph-secgrp"
  description = "Rules related to the terraform ceph test setup"
}

# Allow incomming ssh
resource "openstack_networking_secgroup_rule_v2" "ceph-secgrp_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ceph-secgrp.id
  depends_on = [
    openstack_networking_secgroup_v2.ceph-secgrp
  ]
}

# Allow incomming Ceph
resource "openstack_networking_secgroup_rule_v2" "ceph-secgrp_i" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3000
  port_range_max    = 8000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ceph-secgrp.id
  depends_on = [
    openstack_networking_secgroup_v2.ceph-secgrp
  ]
}

# Allow outgoing Ceph
resource "openstack_networking_secgroup_rule_v2" "ceph-secgrp_e" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3000
  port_range_max    = 8000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ceph-secgrp.id
  depends_on = [
    openstack_networking_secgroup_v2.ceph-secgrp
  ]
}
