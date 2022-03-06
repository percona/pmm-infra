resource "azurerm_mysql_server" "pmmdemo" {
  name                = "pmm-server"
  location            = "East US"
  resource_group_name = azurerm_resource_group.pmmdemo.name

  administrator_login          = var.mysql_login
  administrator_login_password = var.mysql_password

  sku_name   = "B_Gen5_1"
  storage_mb = 32768
  version    = "8.0"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false

  tags = var.default_tags
}

# Create empty DB inside MySQL for accepting sysbench queries
#
resource "azurerm_mysql_database" "pmmdemo_sysbench" {
  name                = "sbtest"
  resource_group_name = azurerm_resource_group.pmm_demo_stand.name
  server_name         = azurerm_mysql_server.pmmdemo_azuredb.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Allow access from PMMDemo-server
#
resource "azurerm_mysql_firewall_rule" "allow_pmmdemo_server" {
  name                = "allow_pmmdemo_server"
  resource_group_name = azurerm_resource_group.pmm_demo_stand.name
  server_name         = azurerm_mysql_server.pmmdemo_azuredb.name
  start_ip_address    = data.terraform_remote_state.pmm_server.outputs.instance_public_ip
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_resource_group" "pmmdemo" {
  name     = "pmm-demo-stand"
  location = var.default_location
  tags     = var.default_tags
}
