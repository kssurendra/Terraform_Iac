resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "CGP_VPC"
  }
}
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    name = "Public_1a"
  }

}
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    name = "Public_1b"
  }

}
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    name = "Private_1a"
  }

}
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    name = "Private_1b"
  }

}
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.main.id
  tags = {
    name = "CGP_IGW"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }
  tags = {
    name = "Public_RT"
  }
}
resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc3" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.public.id

}
resource "aws_route_table_association" "public_assoc4" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.public.id

}
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.main.id # Replace with your VPC ID

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {

    Name = "web-sg"
  }
}

