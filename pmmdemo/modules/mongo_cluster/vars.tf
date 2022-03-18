locals {
  mongo_cluster_name     = "mongo-42"
  provision_scripts_path = "provision_scripts/mongo_42.yml"
}


variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID to launch in."
}

variable "route53_id" {
  type        = string
  description = "ID for route53"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security groups id"
}

variable "instance_type" {
  type        = string
  description = "Instance type for primary instances (rs-0 and rs-1)"
}

variable "config_instance_type" {
  type        = string
  description = "Instance type for backup instances (rs-2)"
}

variable "pmm_server_endpoint" {
  type        = string
  description = "Endpoint of PMM server for agent"
}

variable "pmm_password" {
  type        = string
  description = "Admin password for PMM Server"
}

variable "route53_name" {
    type = string
    description = "Route53 zone name"
}

# OPTIONAL
variable "count_of_chards" {
  type        = number
  description = "Number of Mongo shards"
  default     = 3
}

variable "mongo_disk_size" {
  type    = string
  description = "Size of disk for Mongo shard"
  default = 64
}

variable "mongo_config_disk_size" {
  type    = string
  description = "Size of config instance of Mongo cluster"
  default = 16
}


