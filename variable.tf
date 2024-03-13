variable "publisher_email" {
  description = "The email address of the owner of the service"
  type        = string
  validation {
    condition     = length(var.publisher_email) > 0
    error_message = "The publisher_email must contain at least one character."
  }
}

variable "publisher_name" {
  description = "The name of the owner of the service"
  type        = string
  validation {
    condition     = length(var.publisher_name) > 0
    error_message = "The publisher_name must contain at least one character."
  }
}

variable "sku_apim" {
  description = "The pricing tier of this API Management service"
  type        = string
  validation {
    condition     = contains(["Developer", "Standard", "Premium"], var.sku_apim)
    error_message = "The sku must be one of the following: Developer, Standard, Premium."
  }
}

variable "sku_count" {
  description = "The instance size of this API Management service."
  type        = number
  validation {
    condition     = contains([1, 2], var.sku_count)
    error_message = "The sku_count must be one of the following: 1, 2."
  }
}

variable "apim" {
  type = string
}

variable "connection_string" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "env" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "monitor_name" {
  type = string
}

variable "apim_subnet_id" {
  type = string
}

variable "prefix" {
  type = string
}

variable "api_versions" {
  type = map(object({
    api_display_name = string,
    name             = string,
    service_url      = string,
    path             = string,
    operations = map(object({
      display_name      = string
      method            = string,
      operation_id      = string,
      url_template      = string,
      description       = string,
      enable_parameters = bool
      template_parameters = map(object({
        name        = string,
        type        = string,
        required    = string,
        description = string
      }))
    }))
  }))
}
