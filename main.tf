terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = ">= 2.62.0"
      }
      local = {
        source = "hashicorp/local"
        version = "~> 1.4"
      }
      null = {
        source = "hashicorp/null"
        version = "~> 2.1"
      }
      datadog = {
        source = "DataDog/datadog"
        version = ">= 2.17.0"
      }
  }
}