// Create volume  for deploy host instance root volumes 
resource "openstack_blockstorage_volume_v3" "deploy-os-volumes" {
  for_each = var.deploy-instance
  name     = "${var.project-prefix}-${each.key}-os-volumes"
  size     = 100
  image_id = var.image-id
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "openstack_networking_port_v2" "deploy-internal-network-1-port" {
  for_each       = var.deploy-instance
  name           = "${var.project-prefix}-${each.key}-internal-network-1-port"
  network_id     = openstack_networking_network_v2.internal-network-1.id
  admin_state_up = "true"
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

resource "openstack_networking_port_v2" "deploy-internal-network-2-port" {
  for_each       = var.deploy-instance
  name           = "${var.project-prefix}-${each.key}-internal-network-2-port"
  network_id     = openstack_networking_network_v2.internal-network-2.id
  admin_state_up = "true"
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

resource "openstack_networking_port_v2" "deploy-internal-network-3-port" {
  for_each       = var.deploy-instance
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

resource "openstack_networking_port_v2" "deploy-external-network-1-port" {
  for_each       = var.deploy-instance
  name           = "${var.project-prefix}-${each.key}-external-network-1-port"
  network_id     = openstack_networking_network_v2.external-network-1.id
  admin_state_up = "true"
  security_group_ids = [
    openstack_networking_secgroup_v2.external-network-secgroup.id
    , openstack_networking_secgroup_v2.dmz-allow-secgroup.id
  ]
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.external-network-subnet-1.id
    ip_address = "${var.external-network-1-network-addr}.${each.value}"
  }
  depends_on = [
    openstack_networking_subnet_v2.external-network-subnet-1
  ]
}

// Define cloudinit 
data "template_file" "cloudinit_deploy" {
  template = file("${path.module}/templates/cloud-init.yaml")
  vars = {
    groupwareid     = var.groupwareid
    ssh_public_key  = join("\n", formatlist("    - %s", var.ssh-public-key))
    ssh_private_key = var.ssh-private-key
  }
}

// Create instance for ceph host 
resource "openstack_compute_instance_v2" "deploy-instance" {
  for_each    = var.deploy-instance
  name        = "${var.project-prefix}-${each.key}"
  flavor_name = var.deploy-flavor
  key_pair    = var.keypair-name
  user_data   = data.template_file.cloudinit_deploy.rendered
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.deploy-os-volumes["${each.key}"].id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
  network {
    port = openstack_networking_port_v2.deploy-external-network-1-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.deploy-internal-network-1-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.deploy-internal-network-2-port["${each.key}"].id
  }
  network {
    port = openstack_networking_port_v2.deploy-internal-network-3-port["${each.key}"].id
  }
  depends_on = [
    openstack_networking_subnet_v2.external-network-subnet-1
    , openstack_blockstorage_volume_v3.deploy-os-volumes
    , openstack_networking_port_v2.deploy-external-network-1-port
    , openstack_networking_port_v2.deploy-internal-network-1-port
    , openstack_networking_port_v2.deploy-internal-network-2-port
    , openstack_networking_port_v2.deploy-internal-network-3-port
    , openstack_networking_router_interface_v2.router_1_interface
  ]

}

resource "openstack_networking_floatingip_v2" "deploy-instance-fip" {
  pool       = "external-network-sriov"
  subnet_ids = var.sriov-external-subnet-id
}

resource "openstack_compute_floatingip_associate_v2" "deploy-fip" {
  for_each    = var.deploy-instance
  floating_ip = openstack_networking_floatingip_v2.deploy-instance-fip.address
  instance_id = openstack_compute_instance_v2.deploy-instance["${each.key}"].id
  fixed_ip    = openstack_compute_instance_v2.deploy-instance["${each.key}"].network[0].fixed_ip_v4
}
