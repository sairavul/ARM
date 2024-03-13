locals {
  all_operations = flatten([
    for api_key, api_value in var.api_versions : [
      for operation_key, operation_value in api_value.operations : {
        operation_key       = operation_key
        api_key             = api_key
        display_name        = operation_value["display_name"]
        method              = operation_value["method"]
        operation_id        = operation_value["operation_id"]
        url_template        = operation_value["url_template"]
        description         = operation_value["description"]
        enable_parameters   = operation_value["enable_parameters"]
        template_parameters = operation_value["template_parameters"]
      }
    ]
  ])
}

resource "azurerm_api_management_api" "api" {
  for_each = var.api_versions

  api_management_name   = azurerm_api_management.api.name
  display_name          = each.value.api_display_name
  name                  = each.key
  service_url           = each.value.service_url
  path                  = each.value.path
  protocols             = ["https"]
  resource_group_name   = data.azurerm_resource_group.rg.name
  revision              = "1"
  subscription_required = "false"
}

resource "azurerm_api_management_api_operation" "operations" {
  for_each = {
    for operation_key, operation_value in local.all_operations : operation_key => operation_value
  }

  api_management_name = azurerm_api_management.api.name
  api_name            = azurerm_api_management_api.api[each.value.api_key].name
  display_name        = each.value.display_name
  method              = each.value.method
  operation_id        = each.value.operation_id
  resource_group_name = data.azurerm_resource_group.rg.name
  url_template        = each.value.url_template
  description         = each.value.description
  dynamic "template_parameter" {
    for_each = each.value.enable_parameters ? each.value.template_parameters : {}
    content {
      name        = template_parameter.value.name
      type        = template_parameter.value.type
      required    = template_parameter.value.required
      description = template_parameter.value.description
    }
  }
}
