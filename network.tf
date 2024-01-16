// Create internal network 1
resource "openstack_networking_network_v2" "internal-network-1" {
  name           = "${var.project-prefix}-internal-network-1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal-network-subnet-1" {
  name            = "${var.project-prefix}-internal-network-subnet-1"
  network_id      = openstack_networking_network_v2.internal-network-1.id
  cidr            = "${var.internal-network-1-network-addr}.0/24"
  no_gateway      = true
  dns_nameservers = var.external-dns-nameserver
  depends_on      = [openstack_networking_network_v2.internal-network-1]
}

// Create internal network 2
resource "openstack_networking_network_v2" "internal-network-2" {
  name           = "${var.project-prefix}-internal-network-2"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal-network-subnet-2" {
  name            = "${var.project-prefix}-internal-network-subnet-2"
  network_id      = openstack_networking_network_v2.internal-network-2.id
  cidr            = "${var.internal-network-2-network-addr}.0/24"
  no_gateway      = true
  dns_nameservers = var.external-dns-nameserver
  depends_on      = [openstack_networking_network_v2.internal-network-2]
}

// Create internal network 3
resource "openstack_networking_network_v2" "internal-network-3" {
  name           = "${var.project-prefix}-internal-network-3"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal-network-subnet-3" {
  name            = "${var.project-prefix}-internal-network-subnet-3"
  network_id      = openstack_networking_network_v2.internal-network-3.id
  cidr            = "${var.internal-network-3-network-addr}.0/24"
  no_gateway      = true
  dns_nameservers = var.external-dns-nameserver
  depends_on      = [openstack_networking_network_v2.internal-network-3]
}

// Create external network 1
resource "openstack_networking_network_v2" "external-network-1" {
  name           = "${var.project-prefix}-external-network-1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "external-network-subnet-1" {
  name            = "${var.project-prefix}-external-network-subnet-1"
  network_id      = openstack_networking_network_v2.external-network-1.id
  cidr            = "${var.external-network-1-network-addr}.0/24"
  no_gateway      = false
  dns_nameservers = var.external-dns-nameserver
  depends_on      = [openstack_networking_network_v2.external-network-1]
}

// Create router
resource "openstack_networking_router_v2" "router_1" {
  name                = "${var.project-prefix}-router-1"
  admin_state_up      = true
  external_network_id = var.sriov-external-network_id
}

// Create router interfaces
resource "openstack_networking_router_interface_v2" "router_1_interface" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.external-network-subnet-1.id
  depends_on = [
    openstack_networking_router_v2.router_1,
    openstack_networking_subnet_v2.external-network-subnet-1
  ]
}
