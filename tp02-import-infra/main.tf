resource "aws_instance" "web" {
ami= var.ami_id
instance_type = var.instance_type

tags = {
    Name = "${local.name_prefix}-ec2-${var.resource_suffix}"
  }
  
}


