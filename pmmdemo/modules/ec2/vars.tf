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

variable "instance_type" {
  type        = string
  default     = ""
  description = "(Required) The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance."
}

# OPTIONAL
variable "iam_role_name" {
  type = string
  default = ""
  description = "(Optional) IAM role to attach to EC2 instance"
}

variable "has_public_ip" {
  type        = bool
  default     = "false"
  description = "(Optional) Associate a public ip address with an instance in a VPC. Boolean value."
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

variable "ami_id" {
  type        = string
  description = "Amazon Machine Image AMI"
  default     = "ami-04c56dce2c963b327"
}
