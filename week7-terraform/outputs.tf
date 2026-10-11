output "public_ip" {
  description = "Public IP address of the Week 7 web server"
  value       = openstack_networking_floatingip_v2.web.address
}

output "website_url" {
  description = "URL of the Week 7 website"
  value       = "http://${openstack_networking_floatingip_v2.web.address}"
}
