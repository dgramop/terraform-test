terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
	cidr_block = "10.1.0.0/16"
	instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "Sub1" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.1.0.0/24"
	availability_zone = "us-west-2a"

	tags = {
		Name = "Sub1"
	}
}

resource "aws_security_group" "pubpriv" {
	name = "public"
	vpc_id = aws_vpc.main.id

	ingress {
		from_port = 0
		to_port = 0

		protocol = -1 # semantically equivalent to all, per the docs

		# apply to the public networks
		cidr_blocks = [aws_subnet.Sub1.cidr_block, aws_subnet.Sub2.cidr_block]
		# no ipv6 address assigned to subnets in instructions, so they won't assign any. ipv6_cidr_blocks = [aws_subnet.Sub1.ipv6_cidr_block, aws_subnet.Sub2.ipv6_cidr_block]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = -1

		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

}

resource "aws_subnet" "Sub2" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.1.1.0/24"
	availability_zone = "us-west-2b"

	tags = {
		Name = "Sub2"
	}
}

resource "aws_subnet" "Sub3" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.1.2.0/24"
	availability_zone = "us-west-2a"

	tags = {
		Name = "Sub3"
	}
}

resource "aws_subnet" "Sub4" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.1.3.0/24"
	availability_zone = "us-west-2b"

	tags = {
		Name = "Sub4"
	}
}

resource "aws_network_interface" "rhel_int" {
  subnet_id   = aws_subnet.Sub2.id
  #private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "rhel" {
	# TODO: update AMI
  #ami           = "ami-830c94e3"
	ami = "ami-04a616933df665b44"
  instance_type = "t2.micro"

	# configure interface, which attaches this instance to the sub2 interface
	network_interface {
    network_interface_id = aws_network_interface.rhel_int.id
    device_index         = 0
  }

	root_block_device { 
		# these are 20GiB, though the instructions specify 20GB. Not doing the conversion intentionally, since these sizes are very close to each other.
		volume_size = 20
	}

  tags = {
    Name = "rhel"
  }
}

resource "aws_s3_bucket" "b788787794ad9" {
	bucket = "b788787794ad9"

	lifecycle_rule {
		id = "logs"
		prefix = "logs/"
		enabled = true

		tags = {
			rule = "logs"
			autoclean = "true"
		}

		expiration {
			days = 90
		}
	}

	lifecycle_rule {
		id = "images"
		prefix = "images/"
		enabled = true

		tags = {
			rule = "images"
			autoclean = "true"
		}

		transition {
			days = 90
			storage_class = "GLACIER"
		}
	}
}
