# This Terraform configuration creates a Flex Consumption plan app in Azure Functions 
# with the required Storage account and Blob Storage deployment container.

# Create a storage account
resource "azurerm_storage_account" "sa" {
  name                     = "${var.ENV_NAME}${var.APP_NAME}funcsa"
  resource_group_name      = var.RG_NAME
  location                 = var.LOCATION
  account_tier             = var.SA_ACCOUNT_TIER
  account_replication_type = var.SA_ACCOUNT_REPLICATION_TYPE
}

# Create a storage container
resource "azurerm_storage_container" "sacontainer" {
  name                  = "example-flexcontainer"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# Create a Log Analytics workspace for Application Insights
resource "azurerm_log_analytics_workspace" "loganalyctics" {
  name                = "${var.ENV_NAME}${var.APP_NAME}wsfunclicensing"
  location            = var.LOCATION
  resource_group_name = var.RG_NAME
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create an Application Insights instance for monitoring
resource "azurerm_application_insights" "appinsight" {
  name                = "${var.ENV_NAME}${var.APP_NAME}aifunclicensing"
  location            = var.LOCATION
  resource_group_name = var.RG_NAME
  application_type    = "web"
  workspace_id = azurerm_log_analytics_workspace.loganalyctics.id
}

# Create a service plan
resource "azurerm_service_plan" "asp" {
  name                = "asp-func-${var.ENV_NAME}-${var.APP_NAME}"
  location            = var.LOCATION
  resource_group_name = var.RG_NAME
  sku_name            = "FC1"
  os_type             = "Linux"
}
data "azurerm_subscription" "current" {}

# Create a function app
resource "azurerm_function_app_flex_consumption" "func" {
  name                = "${var.ENV_NAME}${var.APP_NAME}funclicensing"
  resource_group_name = var.RG_NAME
  location            = var.LOCATION
  service_plan_id     = azurerm_service_plan.asp.id
  virtual_network_subnet_id   = var.SUBNET_ID
  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.sa.primary_blob_endpoint}${azurerm_storage_container.sacontainer.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.sa.primary_access_key
  runtime_name                = var.RUNTIME_NAME
  runtime_version             = var.RUNTIME_VERSION
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048
  
  site_config {
    application_insights_key              = azurerm_application_insights.appinsight.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.appinsight.connection_string
    cors {
      allowed_origins     = [
        "https://functions-next.azure.com",
        "https://functions-staging.azure.com",
        "https://functions.azure.com",
        "https://portal.azure.com",
      ]
      support_credentials = true 
    }
  }
  sticky_settings {
    app_setting_names       = [
        "APPINSIGHTS_INSTRUMENTATIONKEY",
        "APPLICATIONINSIGHTS_CONNECTION_STRING ",
        "APPINSIGHTS_PROFILERFEATURE_VERSION",
        "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
        "ApplicationInsightsAgent_EXTENSION_VERSION",
        "XDT_MicrosoftApplicationInsights_BaseExtensions",
        "DiagnosticServices_EXTENSION_VERSION",
        "InstrumentationEngine_EXTENSION_VERSION",
        "SnapshotDebugger_EXTENSION_VERSION",
        "XDT_MicrosoftApplicationInsights_Mode",
        "XDT_MicrosoftApplicationInsights_PreemptSdk",
        "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
    ]
  }
  identity {
    type = "SystemAssigned"  
  }
  app_settings = {
    "KEY_VAULT_NAME"          = "${var.ENV_NAME}${var.APP_NAME}kvfnopswat"
    "SUBSCRIPTION_ID"         = data.azurerm_subscription.current.subscription_id
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
  }
}
resource "azurerm_role_assignment" "func_contributor" {
  scope                = var.RG_ID  # Or use subscription ID or specific resource ID
  role_definition_name  = "Contributor"
  principal_id          = azurerm_function_app_flex_consumption.func.identity[0].principal_id
}

data "azurerm_function_app_host_keys" "fnkeys" {
  name                = azurerm_function_app_flex_consumption.func.name
  resource_group_name = azurerm_function_app_flex_consumption.func.resource_group_name
  depends_on          = [azurerm_function_app_flex_consumption.func]
}
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                  = "${var.ENV_NAME}${var.APP_NAME}kvfnopswat"
  location              = var.LOCATION
  resource_group_name   = var.RG_NAME
  tenant_id             = data.azurerm_client_config.current.tenant_id
  sku_name              = "standard"
  purge_protection_enabled  = false
  depends_on = [azurerm_function_app_flex_consumption.func]
}

resource "azurerm_key_vault_access_policy" "kvAccessFunc" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_function_app_flex_consumption.func.identity[0].principal_id  

  key_permissions = [
    "Get",
  ]
  secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete",
      "Purge",
      "Recover"
  ]
  depends_on          = [azurerm_function_app_flex_consumption.func]
}

resource "azurerm_key_vault_access_policy" "kvAccessTf" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
      "Create",
      "Get",
  ]

  secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
}

resource "azurerm_key_vault_secret" "license" {
  name         = "licenseKey"
  value        = var.LICENSE_KEY
  key_vault_id = azurerm_key_vault.kv.id
  depends_on          = [azurerm_key_vault_access_policy.kvAccessTf]
}
resource "azurerm_key_vault_secret" "apikey" {
  name         = "apiKey"
  value        = var.APIKEY
  key_vault_id = azurerm_key_vault.kv.id
  depends_on          = [azurerm_key_vault_access_policy.kvAccessTf]
}
resource "azurerm_key_vault_secret" "core_user" {
  name         = "coreUser"
  value        = var.CORE_USER
  key_vault_id = azurerm_key_vault.kv.id
  depends_on          = [azurerm_key_vault_access_policy.kvAccessTf]
}
resource "azurerm_key_vault_secret" "core_pwd" {
  name         = "corePwd"
  value        = var.CORE_PWD
  key_vault_id = azurerm_key_vault.kv.id
  depends_on          = [azurerm_key_vault_access_policy.kvAccessTf]
}

resource "azurerm_monitor_action_group" "main" {
  name                = "${var.APP_NAME}-actiongroup"
  resource_group_name = var.RG_NAME
  short_name          = "${var.APP_NAME}actgr"
  azure_function_receiver {
    name                    = azurerm_function_app_flex_consumption.func.name
    function_app_resource_id = azurerm_function_app_flex_consumption.func.id
    function_name           = "http_trigger_licensing"
    http_trigger_url        = "https://${azurerm_function_app_flex_consumption.func.default_hostname}/api/http_trigger_licensing?code=${data.azurerm_function_app_host_keys.fnkeys.default_function_key}"
    use_common_alert_schema = true
  }
}
resource "azurerm_monitor_metric_alert" "start" {
  name                = "${var.ENV_NAME}-${var.APP_NAME}-startalert"
  resource_group_name = var.RG_NAME
  scopes              = [var.VMSS_ID]

  description = "Alerts when VM availability to available state (preview metric)"
  severity    = 3
  frequency   = "PT1M"
  window_size = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = 1

    dimension {
      name     = "VMName"
      operator = "Include"
      values   = ["*"]
    }

  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}


resource "azurerm_role_assignment" "reader" {
  principal_id          = azurerm_function_app_flex_consumption.func.identity[0].principal_id
  role_definition_name  = "Reader"
  scope                 = var.RG_ID
}


resource "azurerm_monitor_metric_alert" "stop" {
  name                = "${var.ENV_NAME}-${var.APP_NAME}-stoptalert"
  resource_group_name = var.RG_NAME
  scopes              = [var.VMSS_ID]

  description = "Alerts when VM availability drops below available state (preview metric)"
  severity    = 3
  frequency   = "PT1M"
  window_size = "PT1M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1

    dimension {
      name     = "VMName"
      operator = "Include"
      values   = ["*"]
    }

  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
resource "azurerm_eventgrid_system_topic" "vm" {
  name                = "${var.ENV_NAME}-${var.APP_NAME}-vm-topic"
  location            = "global"
  resource_group_name = var.RG_NAME
  source_arm_resource_id = data.azurerm_subscription.current.id
  topic_type             = "Microsoft.Resources.Subscriptions"
}


resource "azurerm_eventgrid_system_topic_event_subscription" "vm_events_to_function" {
  name  = "${var.ENV_NAME}-${var.APP_NAME}-vm-events-subscription"
  resource_group_name = var.RG_NAME
  system_topic        = azurerm_eventgrid_system_topic.vm.name

  event_delivery_schema      = "EventGridSchema"
  included_event_types       = ["Microsoft.Resources.ResourceActionSuccess"]

  subject_filter {
    subject_begins_with = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.RG_NAME}/providers/Microsoft.Compute/virtualMachines"
  }

  azure_function_endpoint {
    function_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.RG_NAME}/providers/Microsoft.Web/sites/${azurerm_function_app_flex_consumption.func.name}/functions/event_licensing_handler"
    max_events_per_batch = 1
    preferred_batch_size_in_kilobytes = 64
  }


  advanced_filter {
    string_contains {
      key    = "data.operationName"
      values = [
        "Microsoft.Compute/virtualMachines/start/action",
        "Microsoft.Compute/virtualMachines/deallocate/action",
        "Microsoft.Compute/virtualMachines/powerOff/action"
      ]
    }
  }

  retry_policy {
    max_delivery_attempts = 3
    event_time_to_live    = 1440
  }
  depends_on          = [data.azurerm_subscription.current]
}