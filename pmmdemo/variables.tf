variable "pmm_domain" {
  type        = string
  description = "PMM domain name"
}

variable "owner_email" {
  type        = string
  description = "E-mail for letsencrypt account"
}

# OPTIONAL

variable "project_name" {
  type        = string
  description = "If you have default workspace and want to use different name then you can use the variable"
  default     = "demo"
}

locals {
  environment_name = "${terraform.workspace == "default" ? var.project_name : terraform.workspace}"
}
