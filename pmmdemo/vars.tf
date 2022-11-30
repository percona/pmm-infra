variable "pmm_domain" {
  type        = string
  description = "PMM domain name"
}

variable "owner_email" {
  type        = string
  description = "Email for letsencrypt account"
}

# OPTIONAL

variable "project_name" {
  type        = string
  description = "If you have default workspace and want to use different name then you can use the variable"
  default     = "demo"
}

variable "google_analytics_id" {
  type        = string
  description = "Google Analytics tracking code"
  default     = ""
}

variable "oauth_enable" {
  type        = bool
  description = "Use oauth to connect PMM to the Portal"
  default     = false
}

variable "oauth_client_id" {
  type        = string
  description = "Oauth client ID"
  default     = ""
}

variable "oauth_secret" {
  type        = string
  description = "Oauth client secret"
  default     = ""
}

variable "oauth_scopes" {
  type        = string
  description = "scope for auth"
  default     = ""
}

variable "oauth_url" {
  type        = string
  description = "Oauth domain url"
  default     = ""
}

variable "oauth_token_url" {
  type        = string
  description = "Oauth token URL"
  default     = ""
}

variable "oauth_api_url" {
  type        = string
  description = "Oauth API URL"
  default     = ""
}

variable "oauth_role_attribute_path" {
  type        = string
  description = "Oauth Attribute path"
  default     = ""
}

variable "oauth_signout_redirect_url" {
  type        = string
  description = "Oauth Signout Redirect URL"
  default     = ""
}

locals {
  pmm_server_endpoint = "pmm-server.${aws_route53_zone.demo_local.name}:443"
  environment_name    = terraform.workspace == "default" ? var.project_name : terraform.workspace
}
