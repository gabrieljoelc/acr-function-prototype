provider "azurerm" {
  features {}
}

variable "registry_name" {
}

variable "app_name" {
}

variable "image_name" {
}

variable "tag" {
  default = "latest"
}

variable "creds_acr" {
  type = object({
    username = string
    password = string
  })
}


data "azurerm_container_registry" "self" {
  name                = var.registry_name
  resource_group_name = "proto"
}

data "azurerm_resource_group" "self" {
  name = "proto-linux"
}

resource "azurerm_storage_account" "self" {
  name                     = "${var.app_name}storage"
  resource_group_name      = data.azurerm_resource_group.self.name
  location                 = data.azurerm_resource_group.self.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_app_service_plan" "self" {
  name                    = "${var.app_name}-plan-premium"
  resource_group_name     = data.azurerm_resource_group.self.name
  location                = data.azurerm_resource_group.self.location
  kind                    = "Linux"
  reserved                = true

  sku {
    tier = "Premium"
    size = "P1V2"
  }
}

resource "azurerm_function_app" "self" {
    name                       = "${var.app_name}-function"
    location                   = data.azurerm_resource_group.self.location
    resource_group_name        = data.azurerm_resource_group.self.name
    app_service_plan_id        = azurerm_app_service_plan.self.id
    storage_account_name       = azurerm_storage_account.self.name
    storage_account_access_key = azurerm_storage_account.self.primary_access_key
    version                    = "~3"
    os_type                    = "linux"

    app_settings = {
        FUNCTION_APP_EDIT_MODE                    = "readOnly"
        https_only                                = true
        DOCKER_REGISTRY_SERVER_URL                = data.azurerm_container_registry.self.login_server
        DOCKER_REGISTRY_SERVER_USERNAME           = var.creds_acr.username
        DOCKER_REGISTRY_SERVER_PASSWORD           = var.creds_acr.password
        WEBSITES_ENABLE_APP_SERVICE_STORAGE       = false
    }

    site_config {
      always_on         = true
      # don't need this anymore because we are deploying with Azure Pipelines (see /azure-pipelines.yml)
      #linux_fx_version  = "DOCKER|${data.azurerm_container_registry.self.login_server}/${var.image_name}:${var.tag}"
    }
}
