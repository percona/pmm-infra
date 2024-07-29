# EC2
variable "server_name" {
  type        = string
  description = "Name for server"
}

variable "subnet_id" {
  type = string
  description = "VPC Subnet ID to launch in."
}

variable "route53_id" {
  type        = string
  description = "ID for route53"
}

variable "security_groups" {
  type = list(string)
  description = "List of security groups id"
}

# OPTIONAL
variable "has_public_ip" {
  type        = bool
  default     = "false"
  description = "(Optional) Associate a public ip address with an instance in a VPC. Boolean value."
}

variable "instance_type" {
  type        = string
  default     = ""
  description = "(Required) The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "root_disk_type" {
  type        = string
  default     = "gp3"
  description = "(Optional) The type of volume. Can be 'standard', 'gp2', 'gp3', 'io1', 'io2', 'sc1', or 'st1'. (Default: 'gp2')."
}

variable "root_disk_size" {
  type        = string
  default     = "32"
  description = "Size of the volume in gibibytes (GiB)"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "User data to provide when launching the instance"
}

variable "cpu_credits_mode" {
  type        = bool
  default     = "standard"
  description = "EC2 burstable credits - standard or unlimited"
}
