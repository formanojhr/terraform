variable "whitelist" {
  type = list(string)
}
variable web_image_id {
   type = string
}
variable "web_instance_type" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}





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

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2a"
  tags = {
    "Terraform" : "true"
    // which resources are managed by Terraform helps with things like that
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-west-2b"
  tags = {
    "Terraform" : "true"
    // which resources are managed by Terraform helps with things like that
  }
}

// security group is a firewall that you configure to isolate

resource "aws_security_group" "prod_web" {
  name = "prod_web"
  description = "Allow standard http and https ports inbound and everything outbound"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = var.whitelist
    // use an actual IP address here
  }
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = [
      "0.0.0.0/0"]
    // use an actual IP address here thi allow all ip addresses
  }
  egress {
    from_port = 0
    protocol = "-1"
    //all protocols allowed
    to_port = 0
    // no restrictions in port
    cidr_blocks = [
      "0.0.0.0/0"]
    // allow all
  }

  tags = {
    "Terraform" : "true"
    // which resources are managed by Terraform helps with things like that
  }
}

resource "aws_elb" "prod_web" {
  name = "prod-web"
  // all instances for prod_web
  subnets = [
    aws_default_subnet.default_az1.id,
    aws_default_subnet.default_az2.id]
  security_groups = [
    aws_security_group.prod_web.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  tags = {
    "Terraform" : "true"
    // which resources are managed by Terraform helps with things like that
  }
}

resource "aws_launch_template" "prod_web" {
  name_prefix    = "prod-web"
  image_id       = var.web_image_id
  instance_type  = var.web_instance_type
  tags = {
    "Terraform" : "true"
    // which resources are managed by Terraform helps with things like that
  }
}


resource "aws_autoscaling_group" "prod_web" {
  name = "foobar3-terraform-test"
  desired_capacity = var.web_desired_capacity
  max_size = var.web_max_size
  min_size = var.web_min_size

  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  vpc_zone_identifier = [
    aws_default_subnet.default_az1.id,
    aws_default_subnet.default_az2.id]

  launch_template {
    id = aws_launch_template.prod_web.id
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
    // which resources are managed by Terraform helps with things like that
  }
}

resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb                    = aws_elb.prod_web.id
}


