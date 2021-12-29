##################################################################################
# RESOURCES
##################################################################################

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = var.aws_dynamodb_table
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket        = var.aws_bucket_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }

}

resource "aws_iam_group" "bucket_full_access" {
  name = "${var.aws_bucket_name}-full-access"
}

resource "aws_iam_group" "bucket_read_only" {
  name = "${var.aws_bucket_name}-read-only"
}



# Add members to the group

resource "aws_iam_group_membership" "full_access" {
  name  = "${var.aws_bucket_name}-full-access"
  users = var.full_access_users
  group = aws_iam_group.bucket_full_access.name
}

resource "aws_iam_group_membership" "read_only" {
  name  = "${var.aws_bucket_name}-read-only"
  users = var.read_only_users
  group = aws_iam_group.bucket_read_only.name
}

resource "aws_iam_group_policy" "full_access" {
  name  = "${var.aws_bucket_name}-full-access"
  group = aws_iam_group.bucket_full_access.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_bucket_name}",
                "arn:aws:s3:::${var.aws_bucket_name}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_group_policy" "read_only" {
  name  = "${var.aws_bucket_name}-read-only"
  group = aws_iam_group.bucket_read_only.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.aws_bucket_name}",
                "arn:aws:s3:::${var.aws_bucket_name}/*"
            ]
        }
   ]
}
EOF
}
