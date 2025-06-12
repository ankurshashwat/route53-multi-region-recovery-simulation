variable "project" {
  description = "Project name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
}

variable "primary_ec2_public_ip" {
  description = "Public IP of primary EC2 instance"
  type        = string
}

variable "secondary_ec2_public_ip" {
  description = "Public IP of secondary EC2 instance"
  type        = string
}