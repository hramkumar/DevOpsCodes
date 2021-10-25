provider "aws" {
    region = "us-east-2"
}

variable "ingressrules" {
  type = list(number)
  default = [ 80,443 ]
}

variable "egressrules" {
  type = list(number)
  default = [ 80,443 ]
}

resource "aws_instance" "firstec2" {
  ami = "ami-074cce78125f09d61"
  instance_type = "t2.micro"
  user_data = file("server-script.sh")
  tags = {
    Name = "WebServer"
  }
  security_groups = [aws_security_group.webtraffic.name]
}

resource "aws_instance" "secondec2" {
  ami = "ami-074cce78125f09d61"
  instance_type = "t2.micro"
  tags = {
    Name = "DBServer"
  }

}

resource "aws_eip" "elasticip" {
  instance = aws_instance.firstec2.id
}

resource "aws_security_group" "webtraffic" {
  
  name = "Allow HTTPS"

  dynamic "ingress"  {
    iterator = port
    for_each = var.ingressrules
    content{
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTPS Traffic"
    from_port = port.value
    ipv6_cidr_blocks = [ "::/0" ]
    prefix_list_ids = [  ]
    protocol = "TCP"
    security_groups = [  ]
    self = false
    to_port = port.value
    }
  } 

  dynamic "egress" {
    iterator = port
    for_each = var.egressrules
    content{
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTPS Traffic"
    from_port = port.value
    ipv6_cidr_blocks = [ "::/0" ]
    prefix_list_ids = [  ]
    protocol = "TCP"
    security_groups = [  ]
    self = false
    to_port = port.value
    }
  } 
}

output "EC2ChallengePrivate" {
  value = aws_instance.secondec2.private_ip
  }

output "EC2ChallengePublic" {
  value = aws_eip.elasticip.public_ip
}

