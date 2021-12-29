terraform {
  backend "s3" {
    bucket         = "kubelancer-tf-state-s3-dev"
    key            = "infra/terraform/infra-remote-state/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "kubelancer-tf-statelock-dev"
    encrypt        = true
    profile        = "kubelancer-sandbox-account"
  }
}