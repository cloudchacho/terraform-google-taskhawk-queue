terraform {
  required_version = ">= 0.15"

  experiments = [module_variable_optional_attrs]

  required_providers {
    google = ">= 3.23.0"
  }
}
