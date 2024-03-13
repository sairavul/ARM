data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

locals {
  split_prefix = substr(var.prefix, 2, 2)
}

resource "azurerm_api_management" "api" {
  name                 = lower("${var.env}${var.apim}${local.split_prefix}")
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  publisher_email      = var.publisher_email
  publisher_name       = var.publisher_name
  sku_name             = "${var.sku_apim}_${var.sku_count}"
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.apim_subnet_id
  }
  /************************************************************************************
  * Disabling Multi Region deployment since it gives permissions issues for DR subnet. 
  * This step will be done manually from the Azure Portal for Prod/DR and Staging
  *************************************************************************************
  additional_location {
    location = var.dr_location
    virtual_network_configuration {
      subnet_id = var.apim_additional_subnet_id
    }
  } */
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_logger" "apim_monitor" {
  name                = var.monitor_name
  api_management_name = azurerm_api_management.api.name
  resource_group_name = data.azurerm_resource_group.rg.name

  application_insights {
    instrumentation_key = var.connection_string
  }
}

resource "azurerm_monitor_diagnostic_setting" "sc_diag" {
  name                       = var.monitor_name
  target_resource_id         = azurerm_api_management.api.id
  log_analytics_workspace_id = var.workspace_id
  log {
    category = "GatewayLogs"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = false
    }
  }
}
