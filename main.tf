provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "default"
    }
}

resource "aws_subnet" "az1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet for us-west-2a"
  }
}

resource "aws_subnet" "az2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet for us-west-2b"
  }
}

resource "aws_subnet" "az3" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet for us-west-2c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-routes"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.az1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.az2.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.az3.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_tls"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.default.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    # because they are both the same, they are allowing traffic to and from one port?
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80  
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22

    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}


# resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.web-server-nic.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on = [
#     aws_internet_gateway.gw
#   ]
# }


resource "aws_instance" "server-1" {
  ami = "ami-0ceecbb0f30a902a6"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.az1.id
security_groups = [aws_security_group.allow_web.id]
#   availability_zone = "us-west-2a"
#   key name
  

  user_data = <<-EOF
                 #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    # echo '<head><title>Welcome to Green Team!</title></head>'  >> /var/www/html/index.html
    # echo '<body style="background-color:dark green;">' >> /var/www/html/index.html
    echo '<h1 style="color:black;">This is my Apache Webserver.</h1>' >> /var/www/html/index.html
EOF
    
    tags = {
        Name = "server-1"
    }

}

resource "aws_instance" "server-2" {
  ami = "ami-0ceecbb0f30a902a6"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.az2.id
security_groups = [aws_security_group.allow_web.id]
#   availability_zone = "us-west-2a"
#   key name
  
#   network_interface {
#     device_index = 0
#     network_interface_id = aws_network_interface.web-server-nic.id
#   }

  user_data = <<-EOF
                 #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    # echo '<head><title>Welcome to Green Team!</title></head>'  >> /var/www/html/index.html
    # echo '<body style="background-color:dark green;">' >> /var/www/html/index.html
    echo '<h1 style="color:black;">This is my Apache Webserver.</h1>' >> /var/www/html/index.html
EOF
    
    tags = {
        Name = "server-2"
    }

}

resource "aws_instance" "server-3" {
  ami = "ami-0ceecbb0f30a902a6"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.az3.id
  security_groups = [aws_security_group.allow_web.id]
#   security group
#   availability_zone = "us-west-2a"
#   key name
  
#   network_interface {
#     device_index = 0
#     network_interface_id = aws_network_interface.web-server-nic.id
#   }

  user_data = <<-EOF
                 #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd
    echo '<!DOCTYPE html>' > /var/www/html/index.html
    echo '<html lang="en">' >> /var/www/html/index.html
    # echo '<head><title>Welcome to Green Team!</title></head>'  >> /var/www/html/index.html
    # echo '<body style="background-color:dark green;">' >> /var/www/html/index.html
    echo '<h1 style="color:black;">This is my Apache Webserver.</h1>' >> /var/www/html/index.html
EOF
    
    tags = {
        Name = "server-3"
    }

}