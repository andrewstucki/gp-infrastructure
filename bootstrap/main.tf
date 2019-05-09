terraform {
  required_version = "= 0.11.13"
}

provider "aws" {
  region  = "us-west-1"
  version = "~> 2.8"
}

variable "state_storage" {
  description = "Storage bucket for terraform remote state"
}

variable "lock_table" {
  description = "Lock table for terraform remote state"
}

resource "aws_s3_bucket" "state_storage" {
  bucket = "${var.state_storage}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    "purpose" = "terraform state storage"
  }
}

resource "aws_dynamodb_table" "lock_table" {
  name           = "${var.lock_table}"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    "purpose" = "terraform state storage"
  }
}
