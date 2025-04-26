variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
}

variable "subnet_cidr" {
    description = "CIDR block for the subnet"
    type = string
}

variable "availability_zone" {
    description = "Availability zone for the subnet"
    type = string
}

variable "environment_prefix" {
    description = "Prefix for the environment (e.g., dev, prod)"
    type = string
  
}

variable "my_ip" {
    description = "My IP address"
    type = string
}

variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t2.micro"
}

variable "public_key_location" {
    description = "Location of the public key for SSH access"
    type = string
  
}