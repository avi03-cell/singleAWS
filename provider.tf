#############################################################
# provider.tf
#
# Purpose:
# Configure the AWS provider used by Terraform.
#############################################################

provider "aws" {

  ###########################################################
  # AWS Region
  ###########################################################
  region = var.aws_region

  ###########################################################
  # Default tags
  #
  # These tags are automatically added to every AWS resource
  # created by Terraform.
  ###########################################################
  default_tags {

    tags = local.common_tags

  }

}