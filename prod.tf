variable "whitelist" { # should be more global so that employees can get to the dev, qa or prod if they are in the whitelist 
    type = list(string)
}         
variable "web_image_id" {
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

provider "aws" {
    profile = "default"
    region  = "us-west-2"
}

resource "aws_s3_bucket" "prod_tf_content" {
    bucket = "terraform-course-20210609"
    acl    = "private"
}

resource "aws_default_vpc" "default_vpc" {}

# default subnets for ELB
resource "aws_default_subnet" "default_az1" {
    availability_zone = "us-west-2c"
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_default_subnet" "default_az2" {
    availability_zone = "us-west-2d"
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_security_group" "prod_web_SG" {
    name        = "prod-web-SG"
    description = "Allow std http and https ports inbound and everything outbound"

    # Inbound rules
    ingress {
        # for http
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.whitelist # allows all IPs
    }

        ingress {
        # for https
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.whitelist # allows all IPs
    }

    # Outbound rules
    egress {
        from_port   = 0 # no restrictions in port on tf
        to_port     = 0 # no restrictions in port on tf
        protocol    = "-1" # allows every protocols 
        cidr_blocks = var.whitelist # allows traffic to any IP
    }

    tags = {
        "Terraform" : "true"
    }
}

module "web_app" {
    source = "./modules/web_app"
    
    web_image_id = var.web_image_id
    web_instance_type = var.web_instance_type
    web_desired_capacity = var.web_desired_capacity
    web_max_size = var.web_max_size
    web_min_size = var.web_min_size
    subnets = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
    security_groups = [ aws_security_group.prod_web_SG.id ]
    web_app = "prod"
}