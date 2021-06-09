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
        cidr_blocks = ["0.0.0.0/0"] # allows all IPs
    }

        ingress {
        # for https
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # allows all IPs
    }

    # Outbound rules
    egress {
        from_port   = 0 # no restrictions in port on tf
        to_port     = 0 # no restrictions in port on tf
        protocol    = "-1" # allows every protocols 
        cidr_blocks = ["0.0.0.0/0"] # allows traffic to any IP
    }

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_instance" "prod_web_EC2" {
    count = 2

    ami           = "ami-0235290bfade69c7c"
    instance_type = "t2.nano"

    vpc_security_group_ids = [ 
        aws_security_group.prod_web_SG.id 
    ]

    tags = {
        "Terraform" : "true"
    }
}

# to avoid EIP being dependent on instance creation - decoupling
resource "aws_eip_association" "prod_web_EIP_association" {
    instance_id   = aws_instance.prod_web_EC2[0].id # refers to the first instance
    allocation_id = aws_eip.prod_web_EIP.id
}

resource "aws_eip" "prod_web_EIP" {
    instance = aws_instance.prod_web_EC2[0].id

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_elb" "prod_web_ELB" {
    name            = "prod-web-ELB"
    instances       = aws_instance.prod_web_EC2.*.id # for all the instances
    subnets         = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
    security_groups = [ aws_security_group.prod_web_SG.id ] # so that our instances & ELB can actually talk to each other & talk to the world

    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }

    tags = {
        "Terraform" : "true"
    }
}