
provider "aws" {
 region = "us-east-2"
}

resource "aws_security_group" "lb_sg" {
 name        = "lb_security_group"
 description = "Allow HTTP inbound traffic"
 vpc_id = aws_vpc.main.id

 ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

}
resource "aws_subnet" "public" {
 count = 2
 vpc_id = aws_vpc.main.id
 cidr_block = "10.0.${count.index}.0/24"
 availability_zone = element(["us-east-2a", "us-east-2b"], count.index)
}

resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
}

resource "aws_instance" "web_server" {
 ami = "ami-00ba4cffa98b2aa4b"
 instance_type = "t3.small"
 availability_zone = "us-east-2b"
 vpc_security_group_ids = [aws_security_group.lb_sg.id]
 subnet_id = aws_subnet.public[0].id

 tags = {
   Name = "WebServer"
 }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_lb" "application_lb" {
 name = "Test-Alon"
 internal = false
 load_balancer_type = "application"
 security_groups = [aws_security_group.lb_sg.id]
 subnets = aws_subnet.public[*].id
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
 name     = "web-target-group"
 port     = 80
 protocol = "HTTP"
 vpc_id   = aws_vpc.main.id
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

