# account variables
variable "AWS_REGION" { default = "eu-central-1" }
variable "ACCESS_KEY" {}
variable "SECRET_KEY" {} 
variable "RDS_PSWD" {}


variable "PATH_TO_PUB_KEY" { default = "./your_pub_key.pub"}

# instance variables
variable "INSTANCE_TYPE" { default = "t2.micro" }

data "aws_ami" "ubuntu_ami" {
  owners = ["099720109477"]
  most_recent = true
  
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

output "outputting_ubuntu_ami" {
  value = "${data.aws_ami.ubuntu_ami.id}"
}
