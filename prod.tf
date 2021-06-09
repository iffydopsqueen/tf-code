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

# Launch template for ASG
resource "aws_launch_template" "prod_web_launch" {
    name          = "prod-web-launch"
    image_id      = "ami-0235290bfade69c7c"
    instance_type = "t2.nano"

    tags = {
        "Terraform" : "true"
    }
}

# Auto-scaling group
resource "aws_autoscaling_group" "prod_web_ASG" {
    # availability_zones = [ "us-west-2c", "us-west-2d"] # use this one or the vpc_zone_identifier
    desired_capacity    = 2
    max_size            = 3
    min_size            = 2
    vpc_zone_identifier = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]

    launch_template {
      id      = aws_launch_template.prod_web_launch.id
      version = "$Latest"
    }
    
    tag {
        key                 = "Terraform" 
        value               = "true"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_attachment" "prod_web_ASG_attach" {
  autoscaling_group_name = aws_autoscaling_group.prod_web_ASG.id
  elb                    = aws_elb.prod_web_ELB.id
}

resource "aws_elb" "prod_web_ELB" {
    name            = "prod-web-ELB"
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