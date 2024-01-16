// Create volume  for ceph  host instance root volumes 
resource "openstack_blockstorage_volume_v3" "ceph-os-volumes" {
  for_each = var.ceph-instance
  name     = "${var.project-prefix}-${each.key}-os-volume"
  image_id = var.image-id
  size     = 40
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

// Create volume  for ceph  host instance data volumes 
resource "openstack_blockstorage_volume_v3" "ceph-data-volumes-001" {
  for_each = var.ceph-instance
  name     = "${var.project-prefix}-${each.key}-data-volume-001"
  size     = 65
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

// Create volume  for ceph  host instance data volumes 
resource "openstack_blockstorage_volume_v3" "ceph-data-volumes-002" {
  for_each = var.ceph-instance
  name     = "${var.project-prefix}-${each.key}-data-volume-002"
  size     = 65
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "openstack_networking_port_v2" "ceph-internal-network-1-port" {
  for_each       = var.ceph-instance
  name           = "${var.project-prefix}-${each.key}-internal-network-1-port"
  network_id     = openstack_networking_network_v2.internal-network-1.id
  admin_state_up = "true"
  allowed_address_pairs {
    ip_address = "10.233.0.0/18"
  }
  allowed_address_pairs {
    ip_address = "10.133.0.0/18"
  }
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

resource "openstack_networking_port_v2" "ceph-internal-network-2-port" {
  for_each       = var.ceph-instance
  name           = "${var.project-prefix}-${each.key}-internal-network-2-port"
  network_id     = openstack_networking_network_v2.internal-network-2.id
  admin_state_up = "true"
  allowed_address_pairs {
    ip_address = "10.233.0.0/18"
  }
  allowed_address_pairs {
    ip_address = "10.133.0.0/18"
  }
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal-network-subnet-2.id
    ip_address = "${var.internal-network-2-network-addr}.${each.value}"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.internal-network-secgroup.id
  ]
  depends_on = [
    openstack_networking_subnet_v2.internal-network-subnet-2
  ]
}

resource "openstack_networking_port_v2" "ceph-internal-network-3-port" {
  for_each       = var.ceph-instance
  name           = "${var.project-prefix}-${each.key}-internal-network-3-port"
  network_id     = openstack_networking_network_v2.internal-network-3.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internal-network-subnet-3.id
    ip_address = "${var.internal-network-3-network-addr}.${each.value}"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.internal-network-secgroup.id
  ]
  depends_on = [
    openstack_networking_subnet_v2.internal-network-subnet-3
  ]
}

resource "openstack_networking_port_v2" "ceph-external-network-1-port" {
  for_each       = var.ceph-instance
  name           = "${var.project-prefix}-${each.key}-external-network-1-port"
  network_id     = openstack_networking_network_v2.external-network-1.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.external-network-subnet-1.id
    ip_address = "${var.external-network-1-network-addr}.${each.value}"
  }
  security_group_ids = [
    openstack_networking_secgroup_v2.external-network-secgroup.id
  ]
  depends_on = [
    openstack_networking_subnet_v2.external-network-subnet-1
  ]
}

// Define cloudinit 
data "template_file" "cloudinit-ceph" {
  template = file("${path.module}/templates/cloud-init.yaml")
  vars = {
    groupwareid     = var.groupwareid
    ssh_public_key  = join("\n", formatlist("    - %s", var.ssh-public-key))
    ssh_private_key = var.ssh-private-key
  }
}

// Create instance for ceph host 
resource "openstack_compute_instance_v2" "ceph-instance" {
  for_each    = var.ceph-instance
  name        = "${var.project-prefix}-${each.key}"
  flavor_name = var.ceph-flavor
  key_pair    = var.keypair-name
  user_data   = data.template_file.cloudinit-ceph.rendered
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.ceph-os-volumes["${each.key}"].id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  network {
    port = openstack_networking_port_v2.ceph-external-network-1-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.ceph-internal-network-1-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.ceph-internal-network-2-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.ceph-internal-network-3-port["${each.key}"].id
  }
  depends_on = [
    openstack_networking_subnet_v2.external-network-subnet-1
    , openstack_blockstorage_volume_v3.ceph-os-volumes
    , openstack_networking_port_v2.ceph-external-network-1-port
    , openstack_networking_port_v2.ceph-internal-network-1-port
    , openstack_networking_port_v2.ceph-internal-network-2-port
    , openstack_networking_port_v2.ceph-internal-network-3-port
    , openstack_networking_router_interface_v2.router_1_interface
  ]

}

# Attach volume 
resource "openstack_compute_volume_attach_v2" "ceph-attach-data-volume-001" {
  for_each    = var.ceph-instance
  instance_id = openstack_compute_instance_v2.ceph-instance["${each.key}"].id
  volume_id   = openstack_blockstorage_volume_v3.ceph-data-volumes-001["${each.key}"].id
  depends_on  = [openstack_compute_instance_v2.ceph-instance]
}

# Attach volume 
resource "openstack_compute_volume_attach_v2" "ceph-attach-data-volume-002" {
  for_each    = var.ceph-instance
  instance_id = openstack_compute_instance_v2.ceph-instance["${each.key}"].id
  volume_id   = openstack_blockstorage_volume_v3.ceph-data-volumes-002["${each.key}"].id
  depends_on  = [openstack_compute_instance_v2.ceph-instance]
}
