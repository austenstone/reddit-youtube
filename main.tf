variable "static_web_app_name" {
  type        = string
  description = "The name of the static web app resource."
}

variable "web_app_name" {
  type        = string
  description = "The name of the web app resource."
}

# Configure the Azure provider
terraform {
  backend "azurerm" {
    resource_group_name  = "GitHub"
    storage_account_name = "austengithubstorage"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate.reddit-yt"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "GitHub" {
  name = "GitHub"
}

// Web App
data "azurerm_service_plan" "example" {
  name                = "example-plan"
  resource_group_name = data.azurerm_resource_group.GitHub.name
}

resource "azurerm_linux_web_app" "example" {
  name                = var.web_app_name
  resource_group_name = data.azurerm_resource_group.GitHub.name
  location            = data.azurerm_resource_group.GitHub.location
  service_plan_id     = data.azurerm_service_plan.example.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "example" {
  name           = format("%s-slot", var.web_app_name)
  app_service_id = azurerm_linux_web_app.example.id

  site_config {}
}

// Static Site

resource "azurerm_static_site" "web" {
  name                = var.static_web_app_name
  location            = data.azurerm_resource_group.GitHub.location
  resource_group_name = data.azurerm_resource_group.GitHub.name
}

output "name" {
  value = azurerm_static_site.web.name
}

output "url" {
  value = azurerm_static_site.web.default_host_name
}

output "api_key" {
  value = azurerm_static_site.web.api_key
}

output "app_name" {
  value = azurerm_linux_web_app.example.name
}
