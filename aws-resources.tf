# AWS VPC

resource "aws_vpc" "skr-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "skr-vpc"
  }
}

# AWS SUBNET

resource "aws_subnet" "skr-subnet" {
  vpc_id     = aws_vpc.skr-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "skr-subnet"
  }
}

# AWS INTERNET GATEWAY

resource "aws_internet_gateway" "skr-igw" {
  vpc_id = aws_vpc.skr-vpc.id

  tags = {
    Name = "skr-igw"
  }
}

# AWS ROUTE TABLE

resource "aws_route_table" "skr-rt" {
  vpc_id = aws_vpc.skr-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.skr-igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.skr-igw.id
  }

  tags = {
    Name = "skr-route-table"
  }
}

# AWS ROUTE TABEL SUBNET ASSOCIATION

resource "aws_route_table_association" "skr-rtsa" {
  subnet_id      = aws_subnet.skr-subnet.id
  route_table_id = aws_route_table.skr-rt.id
}

# AWS SECURITY GROUP

resource "aws_security_group" "skr-sg" {
  name        = "allow skr-sg"
  description = "Allow SSH - HTTP inbound traffic"
  vpc_id      = aws_vpc.skr-vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "skr-sg"
  }
}


# AWS EC2 INSTANCE

resource "aws_instance" "skr-ec2" {
  ami           = "ami-0a7cf821b91bcccbc"
  instance_type = "t2.medium"
  key_name = "karthik"
  subnet_id = aws_subnet.skr-subnet.id
  vpc_security_group_ids = [aws_security_group.skr-sg.id]
  user_data = file("example.sh")

  tags = {
    Name = "example-server"
  }
}