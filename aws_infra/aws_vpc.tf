resource "aws_vpc" "webapp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "webapp-vpc"
  }
}

resource "aws_subnet" "webapp_subnet_1" {
    vpc_id = aws_vpc.webapp_vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "webapp-subnet-1"
    }

    availability_zone = "us-west-1a"
}

resource "aws_subnet" "webapp_subnet_2" {
    vpc_id = aws_vpc.webapp_vpc.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "webapp-subnet-2"
    }

    availability_zone = "us-west-1b"
}

resource "aws_db_subnet_group" "webapp_db_subnet_group" {
  count = var.enable_aws_only ? 1 : 0
  name       = "webapp-db-subnet-group"
  subnet_ids = [
    aws_subnet.webapp_subnet_1.id,
    aws_subnet.webapp_subnet_2.id,
  ]

  tags = {
    Name = "webapp-db-subnet-group"
  }
}