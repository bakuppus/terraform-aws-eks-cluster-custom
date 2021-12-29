##################################################################################
# VARIABLES
##################################################################################
variable "profile" {
  type        = string
  description = "AWS profile to use"
  default = "kubelancer-sandbox-account"
}

variable "region" {
  type        = string
  description = "Aws region to use"
  default = "us-west-2"
}


variable "aws_bucket_name" {
  type        = string
  description = "S3 bucket name to store terraform state"
  default = "kubelancer-tf-state-s3-dev"
}

variable "aws_dynamodb_table" {
  type        = string
  description = "DynamoDB table to store terraform lock"
  default = "kubelancer-tf-statelock-dev"
}

variable "full_access_users" {
  type    = list(string)
  default = []

}

variable "read_only_users" {
  type    = list(string)
  default = []
}
