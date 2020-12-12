resource "aws_vpc" "devops" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "devops_project"
  }
}

resource "aws_internet_gateway" "internet_access" {
  vpc_id = aws_vpc.devops.id

  tags = {
    Name = "devops_gateway"
  }
}

resource "aws_subnet" "bastion_subent" {
  vpc_id                    = aws_vpc.devops.id
  cidr_block                = var.bastion_sub_ips
  map_public_ip_on_launch   = true

  tags = {
    Name = "bastion_subent"
  }
}

resource "aws_subnet" "web_subent" {
  vpc_id                    = aws_vpc.devops.id
  cidr_block                = var.web_sub_ips
  map_public_ip_on_launch   = true

  tags = {
    Name = "web_subent"
  }
}

resource "aws_subnet" "app_subent" {
  vpc_id     = aws_vpc.devops.id
  cidr_block = var.app_sub_ips

  tags = {
    Name = "app_subent"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.devops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_access.id
  }

  tags = {
    Name = "Public_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.devops.id

  tags = {
    Name = "Private_route_table"
  }
}

resource "aws_route_table_association" "bastion_association" {
  subnet_id      = aws_subnet.bastion_subent.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "web_association" {
  subnet_id      = aws_subnet.web_subent.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "app_association" {
  subnet_id      = aws_subnet.app_subent.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_network_acl" "bastion_nacl" {
  vpc_id = aws_vpc.devops.id
  subnet_ids = [aws_subnet.bastion_subent.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.your_ip
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.web_sub_ips
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.app_sub_ips
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.your_ip
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.web_sub_ips
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.app_sub_ips
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "bastion_subnets"
  }
}

resource "aws_network_acl" "web_nacl" {
  vpc_id = aws_vpc.devops.id
  subnet_ids = [aws_subnet.web_subent.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.bastion_sub_ips
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.app_sub_ips
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.bastion_sub_ips
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.app_sub_ips
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "web_subnets"
  }
}

resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.devops.id
  subnet_ids = [aws_subnet.app_subent.id]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.bastion_sub_ips
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.web_sub_ips
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.bastion_sub_ips
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.web_sub_ips
    from_port  = 80
    to_port    = 80
  }


  tags = {
    Name = "app_subnets"
  }
}

