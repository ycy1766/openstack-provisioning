// Create volume  for openstack  host instance root volumes 
resource "openstack_blockstorage_volume_v3" "proxy-os-volumes" {
  for_each = var.proxy-instance
  name     = "${var.project-prefix}-${each.key}-os-volume"
  image_id = var.image-id
  size     = 40
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "openstack_networking_port_v2" "proxy-internal-network-1-port" {
  for_each       = var.proxy-instance
  name           = "${var.project-prefix}-${each.key}-internal-network-1-port"
  network_id     = openstack_networking_network_v2.internal-network-1.id
  admin_state_up = "true"
  allowed_address_pairs {
    ip_address = "10.111.1.100/32"
  }
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal-network-subnet-1.id
    ip_address = "${var.internal-network-1-network-addr}.${each.value}"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.internal-network-secgroup.id
  ]
  depends_on = [
    openstack_networking_subnet_v2.internal-network-subnet-1
  ]
}

resource "openstack_networking_port_v2" "proxy-external-network-1-port" {
  for_each       = var.proxy-instance
  name           = "${var.project-prefix}-${each.key}-external-network-1-port"
  network_id     = openstack_networking_network_v2.external-network-1.id
  admin_state_up = "true"
  allowed_address_pairs {
    ip_address = "172.21.1.0/24"
  }
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.external-network-subnet-1.id
    ip_address = "${var.external-network-1-network-addr}.${each.value}"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.external-network-secgroup.id
    , openstack_networking_secgroup_v2.dmz-allow-secgroup.id
  ]
  depends_on = [
    openstack_networking_subnet_v2.external-network-subnet-1
  ]
}

// Define cloudinit 
data "template_file" "cloudinit-proxy" {
  template = file("${path.module}/templates/cloud-init.yaml")
  vars = {
    groupwareid     = var.groupwareid
    ssh_public_key  = join("\n", formatlist("    - %s", var.ssh-public-key))
    ssh_private_key = var.ssh-private-key
  }
}

// Create instance for openstack host 
resource "openstack_compute_instance_v2" "proxy-instance" {
  for_each    = var.proxy-instance
  name        = "${var.project-prefix}-${each.key}"
  flavor_name = var.proxy-flavor
  key_pair    = var.keypair-name
  user_data   = data.template_file.cloudinit-proxy.rendered
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.proxy-os-volumes["${each.key}"].id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  network {
    port = openstack_networking_port_v2.proxy-external-network-1-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.proxy-internal-network-1-port["${each.key}"].id
  }
  depends_on = [
    openstack_networking_subnet_v2.external-network-subnet-1
    , openstack_blockstorage_volume_v3.proxy-os-volumes
    , openstack_networking_port_v2.proxy-external-network-1-port
    , openstack_networking_port_v2.proxy-internal-network-1-port
  ]

}

