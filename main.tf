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

