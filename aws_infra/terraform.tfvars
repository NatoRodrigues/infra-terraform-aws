# terraform.tfvars

ec2_config = {
  instance_type = "t2.micro"
  ami           = "ami-1234567890abcdef"
}

vpc_config = {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc"
  }
}

subnet1_config = {
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "subnet1"
    }
}

subnet2_config = {
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "subnet2"
    }
}

