variable "pmm_domain" {
  type        = string
  description = "PMM domain name"
}

variable "owner_email" {
  type        = string
  description = "Email for letsencrypt account"
}

# OPTIONAL
# These variables can be added to terraform.tfvars for additional customization

variable "project_name" {
  type        = string
  description = "Do not use 'default' namespace"
  default     = "mypmmdemo123"
}

variable "DBAAS" {
    default     = 1
    description = "Control whether to deploy the RDS cluster (0 = no, 1 = yes)"
    type        = number
}

variable "google_analytics_id" {
  type        = string
  description = "Google Analytics tracking code"
  default     = "UA-343802-29"
}

variable "oauth_enable" {
  type        = bool
  description = "Use oauth to connect PMM to the Portal"
  default     = true
}

variable "oauth_scopes" {
  type        = string
  description = "scope for auth"
  default     = "openid profile email offline_access percona"
}

variable "oauth_url" {
  type        = string
  description = "Oauth auth url"
  default     = "https://id.percona.com/oauth2/auskl7vxt4N1CAbjO1t7/v1/authorize"
}

variable "oauth_token_url" {
  type        = string
  description = "Oauth token URL"
  default     = "https://id.percona.com/oauth2/auskl7vxt4N1CAbjO1t7/v1/token"
}

variable "oauth_api_url" {
  type        = string
  description = "Oauth API URL"
  default     = "https://id.percona.com/oauth2/auskl7vxt4N1CAbjO1t7/v1/userinfo"
}

variable "oauth_role_attribute_path" {
  type        = string
  description = "Oauth Attribute path"
  default     = "pmm_demo_role"
}

variable "oauth_signout_redirect_url" {
  type        = string
  description = "Oauth Signout Redirect URL"
  default     = "https://id.percona.com/login/signout?fromURI=https://pmmdemo.dev.percona.net/graph/login"
}

locals {
  pmm_server_endpoint = "pmm-server.${aws_route53_zone.demo_local.name}:443"
  environment_name    = terraform.workspace == "default" ? var.project_name : terraform.workspace
}
