variable "your_ip" {
    description = "input your IP"
    default = "0.0.0.0/0"
}

variable "bastion_sub_ips" {
    description = "bastion subent ips"
    default = "10.0.1.0/24"
}

variable "web_sub_ips" {
    description = "web subent ips"
    default = "10.0.2.0/24"
}

variable "app_sub_ips" {
    description = "app subent ips"
    default = "10.0.3.0/24"
}

variable "ec2_ami" {
    description = "ami used for insatnces"
    default = "ami-0a91d9a59e80900ad"
}

variable "instance_type"{
    description = "ami used for insatnces"
    default = "t2.micro"
}

variable "key_pair_name"{
    description = "key pair"
    default = "devops_project"
}