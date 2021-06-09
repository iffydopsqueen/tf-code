provider "aws" {
    profile = "default"
    region  = "us-west-2"
}

resource "aws_s3_bucket" "prod_tf_content" {
    bucket = "terraform-course-20210609"
    acl    = "private"
}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_security_group" "prod_web" {
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
        aws_security_group.prod_web.id 
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