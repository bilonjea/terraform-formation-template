
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name != "" ? var.key_pair_name : null

  user_data = <<-EOF2
              #!/bin/bash
              dnf update -y || yum update -y || apt-get update -y
              dnf install -y nginx || yum install -y nginx || apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Formation Terraform - ${var.student_id}</h1>" > /usr/share/nginx/html/index.html
              EOF2

  tags = {
    Name = "${local.name_prefix}-ec2-${var.resource_suffix}"
  }
}



resource "aws_instance" "test" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name != "" ? var.key_pair_name : null

  user_data = <<-EOF2
              #!/bin/bash
              dnf update -y || yum update -y || apt-get update -y
              dnf install -y nginx || yum install -y nginx || apt-get install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Formation Terraform - ${var.student_id}</h1>" > /usr/share/nginx/html/index.html
              EOF2

  tags = {
    Name = "${local.name_prefix}-ec2-${var.resource_suffix}"
  }
}


