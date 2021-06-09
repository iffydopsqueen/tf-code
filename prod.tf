provider "aws" {
    profile = "default"
    region  = "us-west-2"
}

resource "aws_s3_bucket" "prod_tf-content" {
    bucket = "terraform-course-20210609"
    acl    = "private"
}

resource "aws_default_vpc" "default-vpc" {}