provider "aws"{
     region="ap-south-1"
     access_key="AKIAVSNYKYNQ5BGL2O5B"
     secret_key="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"
 }
resource "aws_vpc" "my_vpc"{
       cidr_block="10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
      Name = "Vpc-Project"
    }
}

# subnet -1
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-1"
  }
}

# subnet -2
resource "aws_subnet" "subnet-2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-2"
  }
}

# creating internet gw
resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "MyIGW"
    }
}

#creating the route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "route_table-custom"
  }
}

#creating the route
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myigw.id
}

#creating the route association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.public_route_table.id
}
