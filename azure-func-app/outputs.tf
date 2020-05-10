output "resource_group" {
  value = azurerm_resource_group.rg
}

output "function_app" {
  value = azurerm_function_app.function_app
}

output "storage_account" {
  value = azurerm_storage_account.storage_account
}

output "app_service_plan" {
  value = azurerm_app_service_plan.app_service_plan
}

output "app_insights" {
  value = azurerm_application_insights.app_insights
}
