locals {
  mongo_cluster_name      = "mongo-60"
  provision_script_shard  = "provision_scripts/mongo_60/shard.yml"
  provision_script_cfg    = "provision_scripts/mongo_60/cfg.yml"
  provision_script_mongos = "provision_scripts/mongo_60/mongos.yml"
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
  description = "Instance type for primary instances"
}

variable "config_instance_type" {
  type        = string
  description = "Instance type for config database"
}

variable "mongos_instance_type" {
  type        = string
  description = "Instance type for mongos instances"
}

variable "pmm_server_endpoint" {
  type        = string
  description = "Endpoint of PMM server for agent"
}

variable "pmm_password" {
  type        = string
  description = "Admin password for PMM Server"
}

variable "mongodb_ycsb_password" {
  type        = string
  description = "YCSB password for mongos"
}

variable "route53_name" {
  type        = string
  description = "Route53 zone name"
}

# OPTIONAL
variable "count_of_shards" {
  type        = number
  description = "Number of Mongo shards"
  default     = 3
}

variable "count_of_mongos" {
  type        = number
  description = "Number of mongos instances"
  default     = 1
}

variable "mongo_disk_size" {
  type        = string
  description = "Size of disk for Mongo shard"
  default     = 64
}

variable "mongo_config_disk_size" {
  type        = string
  description = "Size of config instance of Mongo cluster"
  default     = 16
}
