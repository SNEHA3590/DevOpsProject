resource "aws_instance" "bastion" {
  ami                       = var.ec2_ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = [aws_security_group.bastion_sg.id]
  key_name                  = var.key_pair_name
  subnet_id                 = aws_subnet.bastion_subent.id

  tags = {
    Name = "bastion"
  }
}


resource "aws_instance" "web" {
  ami                       = var.ec2_ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = [aws_security_group.web_sg.id]
  key_name                  = var.key_pair_name
  subnet_id                 = aws_subnet.web_subent.id

  tags = {
    Name = "web"
  }
}

resource "aws_instance" "app" {
  ami                       = var.ec2_ami
  instance_type             = var.instance_type
  vpc_security_group_ids    = [aws_security_group.app_sg.id]
  key_name                  = var.key_pair_name
  subnet_id                 = aws_subnet.app_subent.id

  tags = {
    Name = "app"
  }
}

