terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}



provider "aws"{
    region = "us-east-2"
}



variable "image_tag" {
  type = string
  default = "rajrishab/challenge2:1.0"
}


data "aws_ssm_parameter" "latest_al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}


variable "subnet_cidr_block"{
  default = ["10.0.1.0/24","10.0.2.0/24"]
  type = list(string)
}

variable "availability_zones" {
  default = ["us-east-2a","us-east-2b"]
  type = list(string)
}

resource "aws_subnet" "subnets"{
  count = "${length(var.subnet_cidr_block)}"
  vpc_id = aws_vpc.main.id
  cidr_block ="${var.subnet_cidr_block[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
}


resource "aws_security_group" "SG1"{

  name        = "example-security-group"
  description = "Allow HTTP and SSH access"
  vpc_id      = aws_vpc.main.id # Replace with your VPC ID or reference

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more specific in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be more specific in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }

}


resource "aws_internet_gateway" "ig"{
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "IGW1"
    }
}

resource "aws_route_table" "route_table"{
    vpc_id = aws_vpc.main.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }


    route{
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }


    tags = {
        Name = "RT1"
    }
}

resource "aws_route_table_association" "route_table_association" {

  count = "${length(var.subnet_cidr_block)}"

  subnet_id      = "${element(aws_subnet.subnets.*.id,count.index)}"
  route_table_id = aws_route_table.route_table.id
}






resource "aws_lb" "lb"{
  name = "lb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.SG1.id]
  subnets = aws_subnet.subnets[*].id
}


resource "aws_lb_target_group" "TG"{

  name = "TG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check{
    path = "/health/"
  }
}


resource "aws_lb_listener" "LBListener" {
  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"

  default_action{
    type = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}




resource "aws_launch_template" "launch_template"{
  name = "launch_template"
  image_id = data.aws_ssm_parameter.latest_al2023_ami.value
  instance_type = "t2.micro"

  network_interfaces{
    associate_public_ip_address = true
    security_groups = [aws_security_group.SG1.id]
  }
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/userdata.tftpl",{
    image_tag = var.image_tag
  }))
}

resource "aws_autoscaling_group" "ASG1" {
  name = "ASG1"
  vpc_zone_identifier = aws_subnet.subnets[*].id
  max_size = 2
  min_size = 1
  desired_capacity = 1


  target_group_arns = [aws_lb_target_group.TG.arn]

  launch_template {
    id = aws_launch_template.launch_template.id
  }
}
