resource "aws_vpc" "webapp_vpc" {
  cidr_block = var.vpc_config.cidr_block
  tags = {
    Name = var.vpc_config.tags["Name"]
  }
}

locals {
  extra_tag = "subnet_tag"
}

resource "aws_subnet" "webapp_subnet_1" {
    vpc_id = aws_vpc.webapp_vpc.id
    cidr_block = var.subnet1_config.cidr_block
    tags = {
      Name = var.subnet1_config.tags["Name"]
    }

    availability_zone = var.subnet1_config.availability_zone
}

resource "aws_subnet" "webapp_subnet_2" {
    vpc_id = aws_vpc.webapp_vpc.id
    cidr_block = var.subnet2_config.cidr_block
    tags = {
        Name = var.subnet2_config.tags["Name"]
    }

    availability_zone = var.subnet2_config.availability_zone
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