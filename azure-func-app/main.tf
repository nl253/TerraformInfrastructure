provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  version = "=2.0"
  features {}
}

locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.app_name}-resource-group"
  location = var.region
  tags     = local.tags
}

resource "azurerm_app_service_plan" "app_service_plan" {
  location            = var.region
  name                = "${var.app_name}-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
  reserved = false
  tags     = local.tags
}

resource "azurerm_application_insights" "app_insights" {
  application_type    = "other"
  location            = var.region
  name                = "${var.app_name}-app-insights"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_function_app" "function_app" {
  app_service_plan_id     = azurerm_app_service_plan.app_service_plan.id
  location                = var.region
  name                    = "${var.app_name}-function-app"
  resource_group_name     = azurerm_resource_group.rg.name
  enable_builtin_logging  = true
  https_only              = var.function_app_https_only
  enabled                 = true
  version                 = var.function_app_runtime_version
  client_affinity_enabled = true
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE     = var.code_zip_uri
    FUNCTIONS_WORKER_RUNTIME     = var.function_app_worker_runtime
    WEBSITE_NODE_DEFAULT_VERSION = var.function_app_node_version
  }
  site_config {
    use_32_bit_worker_process = false
    websockets_enabled        = false
    always_on                 = false
    http2_enabled             = true
    cors {
      allowed_origins = var.function_app_cors_origins
    }
  }
  tags                      = local.tags
  storage_connection_string = azurerm_storage_account.storage_account.primary_connection_string
}

resource "azurerm_storage_account" "storage_account" {
  account_replication_type = var.storage_account_replication
  account_tier             = var.storage_account_tier
  location                 = var.region
  name                     = "${var.app_name}store"
  resource_group_name      = azurerm_resource_group.rg.name
  tags                     = local.tags
}
