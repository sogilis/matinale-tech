# here is the cloud provider configuration

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "eu-west-1"
  profile = "terraform"
}
