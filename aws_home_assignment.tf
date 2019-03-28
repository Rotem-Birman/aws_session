# Configure the AWS Provider
provider "aws" {
	profile    = "rotem_inc"
	region     = "${var.region}"
}

# Create a VPC
resource "aws_vpc" "primary_vpc" {
	cidr_block = "10.1.0.0/16"
	tags = {
		Name = "rotme_inc_vpc"
		}
}

# Retrieve Availability Zones
data "aws_availability_zones" "available" {}

# Configure public subnets
resource "aws_subnet" "public_subnet" {
	count = "${length(var.public_subnet)}"
	vpc_id = "${aws_vpc.primary_vpc.id}"
	availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
	cidr_block = "${var.public_subnet[count.index]}"
	map_public_ip_on_launch = true
	tags = {
		Name = "public-subnet-${count.index}"
		}
}
# Retrieve the public subnet id
output "public_subnet_id" {
	value = ["${aws_subnet.public_subnet.*.id}"]
	} 

# Configure private subnet
resource "aws_subnet" "private_subnet" {
	count = "${length(var.private_subnet)}"
	vpc_id = "${aws_vpc.primary_vpc.id}"
	availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
	cidr_block = "${var.private_subnet[count.index]}"
	tags = {
		Name = "private-subnet-${count.index}"
		}
}

# Retrieve the private subnet id
output "private_subnet_id" {
	value = ["${aws_subnet.private_subnet.*.id}"]
	}

# Define the internet GW
resource "aws_internet_gateway" "gw" {
	vpc_id = "${aws_vpc.primary_vpc.id}"
	tags {
		Name = "Primary IGW"
  }
}

#Define the public route table
resource "aws_route_table" "rt_public" {
	vpc_id = "${aws_vpc.primary_vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}
	tags {
		Name = "Primary public RT"
	}
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "rt_public_asso" {
	count = "${var.count}"
	subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt_public.id}"
}

#Define the private route table
resource "aws_route_table" "rt_private" {
	vpc_id = "${aws_vpc.primary_vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}
	tags {
		Name = "Primary private RT"
	}
}

# Assign the route table to the private Subnet
resource "aws_route_table_association" "rt_private_asso" {
	count = "${var.count}"
	subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt_private.id}"
}

# Create a key pair to use
resource "aws_key_pair" "default" {
	key_name = "rotem_inc"
	public_key = "${var.inst_key}"
}
# Retrieve the IAM role to use
data "aws_iam_role" "my_role" {
	name = "VPC_Role"
}

# Create  public instances
resource "aws_instance" "public_instance" {
	count = "${var.count}"
	vpc_security_group_ids = ["${aws_security_group.sg_public.id}"]
	key_name = "${aws_key_pair.default.key_name}"
	ami = "${var.ubuntu_ami}"
	instance_type = "t2.micro"
	subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
	associate_public_ip_address = true
	tags = {
		Name = "public_instance-${count.index}"
		}
}

# Create  private instances
resource "aws_instance" "private_instance" {
	count = "${var.count}"
	vpc_security_group_ids = ["${aws_security_group.sg_internal.id}"]
	key_name = "${aws_key_pair.default.key_name}"
	ami = "${var.ubuntu_ami}"
	instance_type = "t2.micro"
	subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
	associate_public_ip_address = false
	iam_instance_profile = "${data.aws_iam_role.my_role.name}"
	tags = {
		Name = "private_instance-${count.index}"
		}
}


