provider "aws"{
     region="ap-south-1"
 }

#creating vpc
resource "aws_vpc" "my_vpc"{
        cidr_block="10.0.0.0/16"
        enable_dns_hostnames=true
        enable_dns_support=true
tags = {
      Name="ec2-project"

 }
}

#creating subnet 1
resource "aws_subnet" "subnet-1"{
      vpc_id=aws_vpc.my_vpc.id
      cidr_block="10.0.1.0/24"
     availability_zone="ap-south-1a"
      map_public_ip_on_launch=true
tags = {
    Name="subent-1"
 }
}

#creating subnet-2
resource "aws_subnet" "subent-2" {
  vpc_id=aws_vpc.my_vpc.id
  cidr_block="10.0.2.0/24"
   availability_zone="ap-south-1b"
  map_public_ip_on_launch=true
 tags = {
    Name="Subent-2"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "my-igw"{
    vpc_id=aws_vpc.my_vpc.id
 tags = {
   Name="My-Igw"
 }
}
#creating route table
resource "aws_route_table" "public_route_table"{
       vpc_id=aws_vpc.my_vpc.id
 tags = {
     Name="route_table"
 }
}

#creating aws route
resource "aws_route" "public_route"{
       route_table_id=aws_route_table.public_route_table.id
       destination_cidr_block="0.0.0.0/0"
       gateway_id=aws_internet_gateway.my-igw.id
 }

#creating rout-table association
resource "aws_route_table_association" "public_subnet_association"{
       route_table_id=aws_route_table.public_route_table.id
       subnet_id=aws_subnet.subnet-1.id
}
# creating instance
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

resource "aws_instance" "ec2" {
    subnet_id=aws_subnet.subnet-1.id
    ami="ami-0d0ad8bb301edb745"
    instance_type="t2.micro"
    vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

    key_name="new-key"
   root_block_device{
   volume_size=20
   volume_type="gp3"
   delete_on_termination=true
}
tags = {
    Name="my-first-ec2"
}
user_data=file("index.sh")
 
}
