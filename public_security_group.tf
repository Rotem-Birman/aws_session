# Define the external security group
resource "aws_security_group" "sg_public" {
	name = "vpc_public_sg"
	description = "Allow incoming HTTP connections & SSH access"
	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks =  ["0.0.0.0/0"]
		}
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks =  ["0.0.0.0/0"]
		}
	vpc_id="${aws_vpc.primary_vpc.id}"
	tags {
		Name = "Web_SG"
		}
}