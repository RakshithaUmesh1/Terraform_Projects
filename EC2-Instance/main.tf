provider "aws" {
  region = "ap-south-1"
}

# Creating VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ec2-project"
  }
}

# Creating subnet-1
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1"
  }
}

# Creating subnet-2
resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-2"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-IGW"
  }
}

# Creating Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "public-route-table"
  }
}

# Creating Route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Route Table Association with Subnet-1
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# EC2 Instance using default security group
resource "aws_instance" "ec2" {
  ami                    = "ami-0d0ad8bb301edb745" # Make sure this AMI is valid for ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_1.id
  key_name               = "new-key"
  vpc_security_group_ids = [data.aws_security_group.default.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("index.sh")

  tags = {
    Name = "my-first-ec2"
  }
}

# Get default security group of the VPC
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = aws_vpc.my_vpc.id
}
