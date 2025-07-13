provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "existing" {
  id = "vpc-0a691b1cda1dea4be"
}

data "aws_subnet" "subnet1" {
  id = "subnet-09a9b4fe4e74051b3"
}

data "aws_subnet" "subnet2" {
  id = "subnet-05860172a9327d826"
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_security_group-AlonAlba"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-00ba4cffa98b2aa4b"
  instance_type          = "t3.small"
  availability_zone      = "us-east-2a"
  vpc_security_group_ids = [aws_security_group.lb_sg.id]
  subnet_id              = data.aws_subnet.subnet1.id

  tags = {
    Name = "WebServer"
  }
}

resource "aws_lb" "application_lb" {
  name               = "TEst-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-alonalba"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing.id
}

resource "aws_lb_target_group_attachment" "web_instance_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server.id
}


output "instance_id" {
  value = aws_instance.web_server.id
}

output "lb_dns_name" {
  value = aws_lb.application_lb.dns_name
}


