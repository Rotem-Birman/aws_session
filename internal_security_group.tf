
# Define the internal security group
resource "aws_security_group" "sg_internal"{
	name = "vpc_internal_sg"
	description = "Allow traffic from public subnet"
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
	egress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
	vpc_id = "${aws_vpc.primary_vpc.id}"
	tags {
		Name = "DB_SG"
	}
}