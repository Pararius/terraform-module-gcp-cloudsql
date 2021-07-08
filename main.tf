terraform {
  required_version = ">= 0.15.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.70.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.11.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}
