resource "aws_instance" "name" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public_subnet1.id

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install apache2 -y
                systemctl start apache2
                systemctl enable apache2
                echo "<h1>Hello from Terraform EC2 on Ubuntu 1a</h1>" > /var/www/html/index.html
                EOF

  tags = {
    Name = "Terraform-EC2"
  }

}
resource "aws_instance" "name_1b" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public_subnet2.id

  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install apache2 -y
                systemctl start apache2
                systemctl enable apache2
                echo "<h1>Hello from Terraform EC2 on Ubuntu 1b</h1>" > /var/www/html/index.html
                EOF

  tags = {
    Name = "Terraform-EC2_1b"
  }
}


resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
  vpc_id      = aws_subnet.public_subnet1.vpc_id

  ingress {
    description      = "HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Allow ALB -> web instances on port 80
resource "aws_security_group_rule" "allow_alb_to_instances" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "Allow ALB to reach web instances"
}

resource "aws_lb" "alb" {
  name               = "tf-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "tf-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_subnet.public_subnet1.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Register your existing instances as targets
resource "aws_lb_target_group_attachment" "instance_1a" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.name.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_1b" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.name_1b.id
  port             = 80
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
// ...existing code...