locals {
  azure_region        = "East US"
  azure_mysql_80_name = "azure-mysql-80"
}

# Import the resource group, as there can only be one and it should not
# be recreated/destroyed each time someone wants to rebuild in Azure
data "azurerm_resource_group" "pmmdemo" {
  name = "pmmdemov2"
  provider = azurerm.demo
}

# Create the Azure MySQL "RDS" server
resource "azurerm_mysql_server" "pmmdemo" {
  name     = local.azure_mysql_80_name
  provider = azurerm.demo

  location            = local.azure_region
  resource_group_name = data.azurerm_resource_group.pmmdemo.name

  administrator_login          = "pmmdemo"
  administrator_login_password = random_password.azure_mysql_80_password.result

  sku_name   = "B_Gen5_1"
  storage_mb = 32768
  version    = "8.0"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"

  tags = {
    Terraform       = "Yes"
    iit-billing-tag = "pmm-demo"
    CreatedBy       = var.owner_email
  }
}

# Create an empty MySQL database for sysbench queries
#
resource "azurerm_mysql_database" "pmmdemo_sysbench" {
  name                = "sbtest"
  provider            = azurerm.demo
  resource_group_name = data.azurerm_resource_group.pmmdemo.name
  server_name         = azurerm_mysql_server.pmmdemo.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
}

# Allow access from PMMDemo-server
#
resource "azurerm_mysql_firewall_rule" "allow_pmmdemo_server" {
  name                = "allow_pmmdemo_server"
  provider            = azurerm.demo
  resource_group_name = data.azurerm_resource_group.pmmdemo.name
  server_name         = azurerm_mysql_server.pmmdemo.name
  start_ip_address    = aws_eip.external_ip.public_ip
  end_ip_address      = aws_eip.external_ip.public_ip
}

resource "random_password" "azure_mysql_80_password" {
  length  = 30
  special = true
  upper   = true
  numeric = true
}
