// Create security group for internal network 
resource "openstack_networking_secgroup_v2" "internal-network-secgroup" {
  name        = "${var.project-prefix}_internal_any_allow_secgroup"
  description = "Internal netowrk security group"
}

// Create rules for internal-network-secgroup
resource "openstack_networking_secgroup_rule_v2" "internal-network-1-tcp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.internal-network-1-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-1-udp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.internal-network-1-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-1-icmp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 1
  port_range_max    = 255
  remote_ip_prefix  = "${var.internal-network-1-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-2-tcp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.internal-network-2-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-2-udp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.internal-network-2-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-2-icmp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 1
  port_range_max    = 255
  remote_ip_prefix  = "${var.internal-network-2-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-3-tcp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.internal-network-3-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-3-udp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.internal-network-3-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "internal-network-3-icmp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 1
  port_range_max    = 255
  remote_ip_prefix  = "${var.internal-network-3-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.internal-network-secgroup.id
}

// Create security group for external network 
resource "openstack_networking_secgroup_v2" "external-network-secgroup" {
  name        = "${var.project-prefix}-external-network-secgroup"
  description = "External netowrk security group"
}

// Create rules for external-network-secgroup
resource "openstack_networking_secgroup_rule_v2" "external-network-1-tcp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.external-network-1-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.external-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "external-network-1-udp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.external-network-1-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.external-network-secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "external-network-1-icmp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 1
  port_range_max    = 255
  remote_ip_prefix  = "${var.external-network-1-network-addr}.0/24"
  security_group_id = openstack_networking_secgroup_v2.external-network-secgroup.id
}
// Create security group for dmz
resource "openstack_networking_secgroup_v2" "dmz-allow-secgroup" {
  name        = "${var.project-prefix}-dmz-secgroup"
  description = "DMZ netowrk security group"
}

// Create rules for dmz
resource "openstack_networking_secgroup_rule_v2" "dmz-tcp-allow-rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65000
  remote_ip_prefix  = "${var.dmz-ip-addr}/24"
  security_group_id = openstack_networking_secgroup_v2.dmz-allow-secgroup.id
}
