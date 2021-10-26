provider "aws" {
    region = "us-east-2"  
}

variable "no_of_variables" {
  type = number
}

resource "aws_instance" "firstec2" {
  ami = "ami-074cce78125f09d61"
  instance_type = "t2.micro"
  count = var.no_of_variables
}