# Launch template for ASG - is a requirement for ccreating an ASG
resource "aws_launch_template" "this" { # this is used to describe or point to this module
    name          = "${var.web_app}-launch" # web_app is the name of our module
    image_id      = var.web_image_id
    instance_type = var.web_instance_type

    tags = {
        "Terraform" : "true"
    }
}

# Auto-scaling group
resource "aws_autoscaling_group" "this" {
    # availability_zones = [ "us-west-2c", "us-west-2d"] # use this one or the vpc_zone_identifier
    desired_capacity    = var.web_desired_capacity
    max_size            = var.web_max_size
    min_size            = var.web_min_size
    vpc_zone_identifier = var.subnets

    launch_template {
      id      = aws_launch_template.this.id # since we changed our launch_template name to "this" - it's a convention
      version = "$Latest"
    }
    
    tag {
        key                 = "Terraform" 
        value               = "true"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  elb                    = aws_elb.this.id
}

resource "aws_elb" "this" {
    name            = "${var.web_app}-ELB"
    subnets         = var.subnets
    security_groups = var.security_groups

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