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

output "pmm_demo_postres_13_password" {
  value     = random_password.pmmdemo_postgres_13_password.result
  sensitive = true
}

output "proxysql_monitor_password" {
  value     = random_password.proxysql_monitor.result
  sensitive = true
}

output "percona_server_80_password" {
  value     = random_password.mysql80_sysbench_password.result
  sensitive = true
}

output "percona_xtradb_cluster_80_password" {
  value     = random_password.percona_xtradb_cluster_80_sysbench_password.result
  sensitive = true
}

output "mongodb_42_pmm_user_password" {
  value     = module.mongo_cluster_pmmdemo.mongodb_42_pmm_user_password
  sensitive = true
}

output "mongodb_42_pmm_admin_password" {
  value     = module.mongo_cluster_pmmdemo.mongodb_42_pmm_admin_password
  sensitive = true
}
