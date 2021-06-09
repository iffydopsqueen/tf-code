provider "aws" {
    profile = "default"
    region  = "us-west-2"
}

resource "aws_s3_bucket" "tf-course" {
    bucket = "tf-course-20210609"
    acl    = "private"
}