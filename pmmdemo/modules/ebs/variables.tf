variable "disk_type" {
  type        = string
  default     = "gp3"
  description = "(Optional) The type of volume. Can be 'standard', 'gp2', 'gp3', 'io1', 'io2', 'sc1', or 'st1'. (Default: 'gp2')."
}

variable "disk_size" {
  type        = number
  description = "(Optional) The size of the drive in GiBs."
}

variable "disk_name" {
  type        = string
  description = "Name of disk"
}

variable "device_name" {
  type        = string
  default     = "/dev/sdf"
  description = "(Required) The device name to expose to the instance (for example, /dev/sdh or xvdh)"
}

variable "instance_id" {
  type = string
}
