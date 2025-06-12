variable "region" {
  description = "AWS primary region"
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "AWS secondary region"
  default     = "us-west-2"
}

variable "project" {
  description = "Project name"
  default     = "route-53-multi-region-simulation"
}

variable "github_repo" {
  description = "Github Repository"
  default = "https://github.com/ankurshashwat/route53-multi-region-recovery-simulation.git"
}

variable "db_host" {
  description = "RDS database host"
}

variable "db_user" {
  description = "RDS database username"
  default     = "admin"
}

variable "db_password" {
  description = "RDS database password"
  sensitive   = true
}

variable "db_name" {
  description = "RDS database name"
  default     = "r53_simulation_db"
}

variable "domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
}

variable "local_ip" {
  description = "Local IP address for Route 53 hosted zone"
  type        = string
}