resource "aws_security_group" "bastion_sg" {
  name        = "bastion_security_group"
  description = "bastion security group"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "ingress from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.web_sub_ips,var.app_sub_ips]
  }

  tags = {
    Name = "bastion security group"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_security_group"
  description = "web security group"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "ingerss from bastion sub"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_sub_ips]
  }

  ingress {
    description = "ingerss from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "egress to app subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.app_sub_ips]
  }

  tags = {
    Name = "web security group"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app_security_group"
  description = "app security group"
  vpc_id      = aws_vpc.devops.id

  ingress {
    description = "ingerss from bastion sub"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_sub_ips]
  }

  ingress {
    description = "ingerss from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.web_sub_ips]
  }
  
  tags = {
    Name = "app security group"
  }
}