# Resource Group For Azure, Global resource

resource "azurerm_resource_group" "pmmdemo" {
  name     = "pmmdemov2"
  provider = azurerm.demo
  location = local.azure_region
  tags = {
    Terraform       = "Yes"
    iit-billing-tag = "pmm-demo"
  }
}
