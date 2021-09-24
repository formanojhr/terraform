
//provider is always needed so than terraform knows where to go
// for resources to be created
provider "aws" {
  profile = "terraform-formanojr"
  region = "us-east-1"
}


resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "tf-course-manoj1-20210919"
  acl = "private"
}

resource "aws_default_vpc" "default" {}
