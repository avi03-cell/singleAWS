#############################################################
# versions.tf
#
# Terraform and provider version requirements.
#############################################################

terraform {

  required_version = ">= 1.6.0"

  required_providers {

    aws = {

      source  = "hashicorp/aws"
      version = "~> 5.60"

    }

  }

}