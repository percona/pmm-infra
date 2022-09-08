output "public_ip" {
  value = module.bastion.public_ip
}

output "postgres_pmm_password" {
  value     = random_password.postgres_pmm_password.result
  sensitive = true
}

output "pmm_admin_pass" {
  value     = random_password.pmm_admin_pass.result
  sensitive = true
}
