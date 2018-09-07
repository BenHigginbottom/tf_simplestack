provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/home/ben/.aws/credentials"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical


}


resource "aws_instance" "test" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "bentest"

  tags {
    Terraformed = "true"
  }
  
}

output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}

output "Public_IP" {
  value = "${aws_instance.test.public_ip}"
}
