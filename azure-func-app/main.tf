provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  version = "=2.0"
  features {}
}

resource "azurerm_app_service_plan" "app_service_plan" {
  location = var.region
  name = "${var.app_name}-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_function_app" "function_app" {
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  location = var.region
  name = "${var.app_name}-function-app"
  resource_group_name = azurerm_resource_group.rg.name
  enable_builtin_logging = true
  https_only = true
  enabled = true
  version = var.function_app_runtime_version
  client_affinity_enabled = true
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = var.function_app_run_from_package ? "1" : ""
    FUNCTIONS_WORKER_RUNTIME = var.function_app_worker_runtime
    WEBSITE_NODE_DEFAULT_VERSION = var.function_app_node_version
  }
  site_config {
    use_32_bit_worker_process = false
    websockets_enabled = false
    always_on = false
    http2_enabled = true
    cors {
      allowed_origins = var.function_app_cors_origins
    }
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
  storage_connection_string = azurerm_storage_account.storage_account.primary_connection_string
}

resource "azurerm_resource_group" "rg" {
  name = "testResourceGroup"
  location = var.region
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_storage_account" "storage_account" {
  account_replication_type = "LRS"
  account_tier = "Standard"
  location = var.region
  name = "${var.app_name}store"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
