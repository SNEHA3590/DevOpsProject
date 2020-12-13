
Steps followed in code:

1. Create VPC
2. Create 2 Private and 1 Public Subnets
3. Create 1 Internet Gateway - 3.1 Create a new RT and assign IGW to it.
4. 
    4.1 --> Create Terraform BASTION Security Group
    4.2 --> Create Terraform_BASTION Instance and attach devops_project keypair
5. 
    5.1 --> Create Terraform Web Security Group
    5.2 --> Create Terraform_Web Instance and attach devops_project keypair
6. 
    6.1 --> Create Terraform APP Security Group
    6.2 --> Create Terraform_APP Instance and attach devops_project keypair
7. Create ELB and assign it to Web Server.


Steps to setup 
 1. Install Terraform CLI(https://www.terraform.io/downloads.html)
 2. Install AWS CLI(https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi)
 3. Clone the Project
 4. Open GitBash and do aws configure using access key and secret key
 5. Run the commands, Terraform init, Terraform plan, Terraform apply

