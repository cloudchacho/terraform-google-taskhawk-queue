terraform {
  required_version = ">= 0.15"

  experiments = [module_variable_optional_attrs]

  required_providers {
    google = ">= 4.51.0"
  }
}
