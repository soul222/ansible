provider "aws" {
  region     = "eu-central-1"
 
}

resource "aws_vpc" "my_app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.environment_prefix}-vpc"
  }
}

resource "aws_subnet" "my_app_subnet" {
  vpc_id                  = aws_vpc.my_app_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone

  tags = {
    Name = "${var.environment_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "my_app_internet_gateway" {
  vpc_id = aws_vpc.my_app_vpc.id

  tags = {
    Name = "${var.environment_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "my_app_route_table" {
  vpc_id = aws_vpc.my_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_app_internet_gateway.id
  }

  tags = {
    Name = "${var.environment_prefix}-route-table"
  }
}

resource "aws_route_table_association" "my_app_route_table_association" {
  subnet_id      = aws_subnet.my_app_subnet.id
  route_table_id = aws_route_table.my_app_route_table.id
}

resource "aws_security_group" "my_app_security_group" {
  name   = "${var.environment_prefix}-security-group"
  vpc_id = aws_vpc.my_app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_prefix}-security-group"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.environment_prefix}-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "my_app_instance" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.my_app_security_group.id]
  subnet_id                   = aws_subnet.my_app_subnet.id
  user_data                   = file("entry_script.sh")

  tags = {
    Name = "${var.environment_prefix}-server"
  }
}
