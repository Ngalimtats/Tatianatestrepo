provider "aws" {
  region  = "us-east-1"
  profile = "default"

}

resource "aws_instance" "my-first-server" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.app-subnet.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "ubuntu"
  }

}
resource "aws_vpc" "prod" {
  cidr_block       = "10.0.0.0/16"
  

  tags = {
    Name = "production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "gw"
  }
}

#create a route table
resource "aws_route_table" "prod-routetable" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

#subnet
resource "aws_subnet" "app-subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1"

  tags = {
    Name = "application"
  }
}
resource "aws_subnet" "db-subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1"

  tags = {
    Name = "database"
  }
}

# resource "aws_s3_bucket" "dev_bucket" {
#   bucket = "yvebucket2012"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
