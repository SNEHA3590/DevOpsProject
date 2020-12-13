// VPC Creation
resource "aws_vpc" "terraform" {
  cidr_block       = "20.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform VPC"
  }
}

// Subnets Creation
resource "aws_subnet" "terraform_subnet_1" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "20.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch   = true
  
  tags = {
    Name = "bastion subnet"
  }
}

resource "aws_subnet" "terraform_subnet_2" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "20.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Web subnet"
  }
}

resource "aws_subnet" "terraform_subnet_3" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "20.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "App subnet"
  }
}

// Internet Gateway Creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "Terraform_IGW"
  }
}

// Route Table Creation
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "terraform_internet_route"
  }
}

// Route Table - Subnet Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.terraform_subnet_1.id
  route_table_id = aws_route_table.rt.id
}

// Route Table - Subnet Association
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.terraform_subnet_2.id
  route_table_id = aws_route_table.rt.id
}

// Route Table - Subnet Association
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.terraform_subnet_3.id
  route_table_id = aws_route_table.rt.id
}

// Create BASTION Instance and Security Group

//Create Security Group for BASTION
resource "aws_security_group" "sgpublic" {
  name = "Terraform_BASTION_SG"
  description = "Allow Ping and SSH access "

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"] //can provide ip address
  }


  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "Terraform BASTION SG"
  }
}

//Create Instance and Attach Security Group

# Define webserver inside the public subnet
resource "aws_instance" "Terraform_BASTION" {
   ami  = "ami-0a91d9a59e80900ad"
   instance_type = "t2.micro"
   key_name = "devops_project"
   subnet_id = aws_subnet.terraform_subnet_1.id
   vpc_security_group_ids = ["${aws_security_group.sgpublic.id}"]

  tags = {
    Name = "Terraform BASTION"
  }
}

// Create Web Instance and Security Group

//Create Security Group for Web Server
resource "aws_security_group" "sgweb" {
  name = "Terraform_WEB_SG"
  description = "Allow Ping, HTTP and SSH access from terraform_subnet_1"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["20.0.1.0/24"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["20.0.3.0/24"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["20.0.1.0/24"]
  }
  
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "Terraform WEB SG"
  }
}

//Create Instance and Attach Security Group

# Define webserver inside the public subnet
resource "aws_instance" "Terraform_WEB" {
   ami  = "ami-0a91d9a59e80900ad"
   instance_type = "t2.micro"
   key_name = "devops_project"
   subnet_id = aws_subnet.terraform_subnet_2.id
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   user_data = file("${path.module}/startup.sh")
   
  tags = {
    Name = "Terraform WEB"
  }
}

// Create App Instance and Security Group

//Create Security Group for App Server
resource "aws_security_group" "sgapp" {
  name = "Terraform_APP_SG"
  description = "Allow SSH access from terraform_subnet_2"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["20.0.1.0/24"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["20.0.1.0/24"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["20.0.2.0/24"]
  }


  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "Terraform APP SG"
  }
}

//Create Instance and Attach Security Group

# Define webserver inside the public subnet
resource "aws_instance" "Terraform_APP" {
   ami  = "ami-0a91d9a59e80900ad"
   instance_type = "t2.micro"
   key_name = "devops_project"
   subnet_id = aws_subnet.terraform_subnet_3.id
   vpc_security_group_ids = ["${aws_security_group.sgapp.id}"]

  tags = {
    Name = "Terraform APP"
  }
}

//Create Security Group for CLB
resource "aws_security_group" "sgclb" {
  name = "Terraform_CLB"
  description = "Allow HTTP access from ipv4 and ipv6"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "Terraform CLB SG"
  }
}

//Create Classic Load Balancer and associate it to our Terraform Web 
resource "aws_elb" "clb" {
  name               = "terraform-clb"
  subnets            = [aws_subnet.terraform_subnet_1.id]
  security_groups    = [aws_security_group.sgclb.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  
  listener {
    instance_port     = 443
    instance_protocol = "https"
    lb_port           = 443
    lb_protocol       = "https"
	ssl_certificate_id = "arn:aws:acm:us-east-1:286281125721:certificate/d052023d-b73e-48f3-b6a4-c82c4ad6091c"
  }
  	
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  instances                   = [aws_instance.Terraform_WEB.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "terraform-clb"
  }
}