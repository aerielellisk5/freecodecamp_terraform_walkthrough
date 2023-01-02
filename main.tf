provider "aws" {
  region = "us-west-2"
}

# resource "aws_instance" "web" {
#   ami           = "ami-0ceecbb0f30a902a6"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "ubuntu"
#   }
# }

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production"
    }
}



