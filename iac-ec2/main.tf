terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

    tags = {
      Name = "minha-vpc"
    }
}
  resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "minha-subnet"
  }
 }

  resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

    tags = {
      Name = "meu-ig"
    }
  }

  resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "minha-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "Teste-NT-key"
  public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt1l276Nlz5ioB7ZQKiy3l0u8MvQzs65cRW3BuGDFOpDct2utv+/xChg0xy+okKgTqaHNVAclate88EUHBaahQkb/nx61/w/QVPzgMZe1hY3RdEIrGyeEaTL00k6XPSaXXvRdlzgqAUiGUhk8Rh8QhhZZURwZQwkEilJ3o1INBp2ZA3R9YbhfmynGbNQyC8fuSiHsqNm2dcTvMYDi12u53kuCyLWwPkTXIkb1KMqS2PoQ7bsG8FiPF29N03lM8H0blzRHJzalZtXvydQfGoyER52aaJvj+v2anvuXHqCgWj9B5tXuUiXAS1Vv5Z135KDyeIgQQl+w35RvN8a4m18sXQIDAQAB"
}

resource "aws_instance" "ec2" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  
  tags = {
    Name = "minha-ec2"
  }
}

resource "aws_security_group" "security_group" {
  name        = "testeNT-security_group"
  description = "SG Liberado"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Liberacao de todas as portas"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "testeNT-security_group"
  }
}

  output "ip_ec2" {
    value = aws_instance.ec2.public_ip
  }