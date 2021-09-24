
//provider is always needed so than terraform knows where to go
// for resources to be created
provider "aws" {
  profile = "terraform-formanojr"
  region = "us-west-2"
}


resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "tf-course-manoj1-20210919"
  acl = "private"
}

resource "aws_default_vpc" "default" {}

// security group is a firewall that you configure to isolate

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "Allow standard http and https ports inbound and everything outbound"
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]// use an actual IP address here
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]// use an actual IP address here thi allow all ip addresses
  }
  egress {
    from_port = 0
    protocol  = "-1"//all protocols allowed
    to_port   = 0  // no restrictions in port
    cidr_blocks = ["0.0.0.0/0"]// allow all
  }

  tags = {
    "Terraform" : "true"  // which resources are managed by Terraform helps with things like that
  }
}

resource "aws_instance" "prod_web" {
  ami           = "ami-091dc5ac6b1d84e27"
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]
    tags = {
      "Terraform" : "true"  // which resources are managed by Terraform helps with things like that
    }
}

resource "aws_eip" "prod_web" {
  instance = aws_instance.prod_web.id

  tags = {
    "Terraform" : "true"  // which resources are managed by Terraform helps with things like that
  }
}