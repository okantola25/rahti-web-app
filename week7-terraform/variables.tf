
variable "project_network" {
  description = "Name of the existing CSC cPouta project network"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the cloud resources"
  type        = string
  default     = "week7-web"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key on my computer"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_allowed_cidr" {
  description = "Public IP address allowed to connect over SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "Enter a valid CIDR, such as 203.0.113.45/32."
  }
}

variable "image_name" {
  description = "Linux image for the virtual machine"
  type        = string
}

variable "flavor_name" {
  description = "Virtual machine size"
  type        = string
}

variable "student_name" {
  description = "Name displayed on the web page"
  type        = string
}

variable "page_message" {
  description = "Message displayed on the web page"
  type        = string
  default     = "Week 7 - Infrastructure as Code with OpenTofu"
}
