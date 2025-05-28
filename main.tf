
provider "aws" {
  alias  = "east"
  region = "us-east-2"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

resource "aws_security_group" "security_1" {
  provider = aws.east
  name     = "security_1"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "websecuritygroup-east"
  }
}

resource "aws_security_group" "security_2" {
  provider = aws.west
  name     = "security_2"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name = "websecuritygroup-west"
  }
}

resource "aws_instance" "my-ec2-1" {
  provider        = aws.east
  ami             = "ami-060988b0dff2faa7c"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.security_1.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
            EOF

 
  tags = {
    Name = "instance1"
    Application = "nginx_server1"
  }
}

resource "aws_instance" "my-ec2-2" {
  provider        = aws.west
  ami             = "ami-0ec1ab28d37d960a9"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.security_2.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
            EOF

  tags = {

    Name= "instance2"
    Application = "nginx-server2"
  }

}


