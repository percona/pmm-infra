output "public_ip" {
  value = module.bastion.public_ip
}

# output "rds_postgresql_16_password" {
#   value     = random_password.rds_postgresql_16_password.result
#   sensitive = true
# }
# 
# output "rds_mysql_80_password" {
#   value     = random_password.rds_mysql_80_password.result
#   sensitive = true
# }

output "percona_server_80_password" {
  value     = random_password.mysql80_sysbench_password.result
  sensitive = true
}

output "percona_server_84_password" {
  value     = random_password.mysql84_sysbench_password.result
  sensitive = true
}

output "percona_server_84_group_replication_password" {
  value     = random_password.percona_server_84_group_replication_sysbench_password.result
  sensitive = true
}

output "percona_xtradb_cluster_80_root_password" {
  value     = random_password.percona_xtradb_cluster_80_root_password.result
  sensitive = true
}

output "percona_xtradb_cluster_80_sysbench_password" {
  value     = random_password.percona_xtradb_cluster_80_sysbench_password.result
  sensitive = true
}

output "pmm_admin_pass" {
  value     = random_password.pmm_admin_pass.result
  sensitive = true
}

output "postgresql_16_pmm_password" {
  value     = random_password.postgresql_16_pmm_password.result
  sensitive = true
}

output "postgresql_16_sysbench_password" {
  value     = random_password.postgresql_16_sysbench_password.result
  sensitive = true
}

output "mongodb_ycsb_password" {
  value     = random_password.mongodb_ycsb_password.result
  sensitive = true
}

output "proxysql_admin_password" {
  value     = random_password.proxysql_admin.result
  sensitive = true
}

output "proxysql_monitor_password" {
  value     = random_password.proxysql_monitor.result
  sensitive = true
}

output "mongodb_60_pmm_user_password" {
  value     = module.mongo_cluster_pmmdemo.mongodb_60_pmm_user_password
  sensitive = true
}

output "mongodb_60_percona_admin_password" {
  value     = module.mongo_cluster_pmmdemo.mongodb_60_percona_admin_password
  sensitive = true
}
