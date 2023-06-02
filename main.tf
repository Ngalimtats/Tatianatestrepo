provider "aws" {
  region  = "us-east-1"
  profile = "default"

}

resource "aws_instance" "my-first-server" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.app-subnet.id
  availability_zone = "us-east-1a"
  security_groups = [aws_security_group.allow_webtraffic.id]

user_data = <<-EOF
            #/bin/basj
            sudo apt update -y
            sudo apt install apache2 -y
            sudo systemctl start apache2
            sudo bash -c echo 'wirfon first server' > /var/www/html/index.html
            EOF


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
  availability_zone = "us-east-1a"

  tags = {
    Name = "application"
  }
}
resource "aws_subnet" "db-subnet" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "database"
  }
}

# #Associate subnet with route table
# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.app-subnet.id
#   route_table_id = aws_route_table.prod-routetable.id
# }
# resource "aws_route_table_association" "b" {
#   gateway_id     = aws_internet_gateway.gw.id
#   route_table_id = aws_route_table.prod-routetable.id
# }

#Security Groups
resource "aws_security_group" "allow_webtraffic" {
  name        = "allow_webtraffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
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

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#Network Interface
resource "aws_network_interface" "nic" {
 subnet_id       = aws_subnet.app-subnet.id
  #private_ips     = ["10.0.0.50"]
  #security_groups = [aws_security_group.web.id]

  attachment {
    instance     = aws_instance.my-first-server.id
    device_index = 1
  }
}


resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.nic.id
  #associate_with_private_ip = "10.0.0.10"
  depends_on = [ aws_internet_gateway.gw ]
}


