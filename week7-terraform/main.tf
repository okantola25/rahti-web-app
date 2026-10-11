
# Look up the existing CSC project network
data "openstack_networking_network_v2" "project" {
  name = var.project_network
}

# SSH key pair: only the public key is uploaded
resource "openstack_compute_keypair_v2" "web" {
  name       = "${var.name_prefix}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# Security group (firewall)
resource "openstack_networking_secgroup_v2" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "SSH from my IP, HTTP from anywhere. Managed by OpenTofu."
}

# Allow SSH only from your IP address
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
}

# Allow HTTP from anywhere
resource "openstack_networking_secgroup_rule_v2" "http" {
  security_group_id = openstack_networking_secgroup_v2.web.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
}

# Network port for the VM
resource "openstack_networking_port_v2" "web" {
  name               = "${var.name_prefix}-port"
  network_id         = data.openstack_networking_network_v2.project.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.web.id]
}

# Virtual machine with automatic web server setup
resource "openstack_compute_instance_v2" "web" {
  name        = "${var.name_prefix}-vm"
  image_name  = var.image_name
  flavor_name = var.flavor_name
  key_pair    = openstack_compute_keypair_v2.web.name

  # cloud-init installs the web server at first boot
  user_data = replace(templatefile("${path.module}/cloud-init.yaml", {
    student_name = var.student_name
    page_message = var.page_message
  }), "\r\n", "\n")

  network {
    port = openstack_networking_port_v2.web.id
  }
}

# Public IP address attached to the VM
resource "openstack_networking_floatingip_v2" "web" {
  pool    = "public"
  port_id = openstack_networking_port_v2.web.id
}
