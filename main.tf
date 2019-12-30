variable "keyname" {
    type    = string
}

data "aws_availability_zones" "available" {
	state	= "available"
}

data "aws_ami" "amazon-linux-2" {
	most_recent	= true
	owners		= ["amazon"]
	name_regex	= "^amzn2-ami-hvm*"
}

resource "aws_vpc" "this" {
	cidr_block	= "10.10.0.0/16"
	tags 		= {
		Name 	= "EC2MeshVPC"
	}
}

resource "aws_route_table" "application" {
	vpc_id			= aws_vpc.this.id

	route {
		cidr_block	= "0.0.0.0/0"
		network_interface_id	= aws_network_interface.netropy_app.id
	}

	tags 			= {
		Name 		= "application"
	}
}

resource "aws_route_table" "netropy" {
	vpc_id			= aws_vpc.this.id

	route {
		cidr_block	= "0.0.0.0/0"
		gateway_id	= aws_internet_gateway.this.id
	}

	tags 			= {
		Name 		= "netropy"
	}
}

resource "aws_route_table" "igw" {
	vpc_id			= aws_vpc.this.id

	route {
		cidr_block	= "10.10.1.0/24"
		network_interface_id	= aws_network_interface.netropy_netropy.id
	}

	tags 			= {
		Name 		= "igw"
	}
}

resource "aws_route_table_association" "application" {
	subnet_id		= aws_subnet.application.id
	route_table_id	= aws_route_table.application.id
}

resource "aws_route_table_association" "netropy" {
	subnet_id		= aws_subnet.netropy.id
	route_table_id	= aws_route_table.netropy.id
}

resource "aws_route_table_association" "mgmt" {
	subnet_id		= aws_subnet.mgmt.id
	route_table_id	= aws_route_table.netropy.id
}

resource "aws_route_table_association" "igw" {
	gateway_id		= aws_internet_gateway.this.id
	route_table_id	= aws_route_table.igw.id
}

resource "aws_internet_gateway" "this" {
	vpc_id	= aws_vpc.this.id
}

resource "aws_subnet" "mgmt" {
	availability_zone	= data.aws_availability_zones.available.names[0]
	cidr_block		= "10.10.0.0/24"
	vpc_id			= aws_vpc.this.id
	tags 			= {
		Name 		= "mgmt"
	}
}

resource "aws_subnet" "application" {
	availability_zone	= data.aws_availability_zones.available.names[0]
	cidr_block		= "10.10.1.0/24"
	vpc_id			= aws_vpc.this.id
	tags 			= {
		Name 		= "application"
	}
}

resource "aws_subnet" "netropy" {
	availability_zone	= data.aws_availability_zones.available.names[0]
	cidr_block		= "10.10.2.0/24"
	vpc_id			= aws_vpc.this.id
	tags 			= {
		Name 		= "netropy"
	}
}

resource "aws_default_security_group" "this" {
	vpc_id			= aws_vpc.this.id

	ingress {
		protocol	= -1
		from_port	= 0
		to_port		= 0
		cidr_blocks	= ["0.0.0.0/0"]
	}

	egress {
		protocol	= "-1"
		from_port	= 0
		to_port		= 0
		cidr_blocks	= ["0.0.0.0/0"]
	}
}

resource "aws_instance" "application1" {
	ami				= data.aws_ami.amazon-linux-2.id
	instance_type	= "t3.nano"
	key_name		= var.keyname
	subnet_id		= aws_subnet.application.id

	tags = {
		Name		= "application 1"
	}
}

resource "aws_instance" "application2" {
	ami				= data.aws_ami.amazon-linux-2.id
	instance_type	= "t3.nano"
	key_name		= var.keyname
	subnet_id		= aws_subnet.application.id

	tags = {
		Name		= "application 2"
	}
}

# resource "aws_instance" "netropy" {
# 	ami					= data.aws_ami.amazon-linux-2.id
# 	instance_type		= "t3.small"
# 	key_name			= var.keyname

# 	network_interface {
# 		network_interface_id	= aws_network_interface.netropy_mgmt.id
# 		device_index		= 0
# 	}

# 	network_interface {
# 		network_interface_id	= aws_network_interface.netropy_app.id
# 		device_index		= 1
# 	}

# 	network_interface {
# 		network_interface_id	= aws_network_interface.netropy_netropy.id
# 		device_index		= 2
# 	}

# 	tags = {
# 		Name 			= "Netropy Emulator"
# 	}

# 	user_data = <<-EOT
# 		#! /bin/bash
# 		yum install -y iproute-tc
#         sysctl -w net.ipv4.ip_forward=1
# 		tc qdisc add dev eth1 root netem delay 100ms
# 		ip route add 52.52.216.52/32 via 10.10.2.1
# 	EOT
# }

data "aws_ami" "netropy" {
	most_recent	= true
	name_regex	= "NetropyCE-\\d{1}-\\d{1}"
	owners		= ["056058814734"]
}

resource "aws_instance" "netropy" {
	ami			= data.aws_ami.netropy.id
	instance_type		= "t3.xlarge"
	key_name			= var.keyname

	network_interface {
		network_interface_id	= aws_network_interface.netropy_mgmt.id
		device_index		= 0
	}

	network_interface {
		network_interface_id	= aws_network_interface.netropy_app.id
		device_index		= 1
	}

	network_interface {
		network_interface_id	= aws_network_interface.netropy_netropy.id
		device_index		= 2
	}

	tags = {
		Name 			= "Netropy Emulator"
	}
}

resource "aws_network_interface" "netropy_mgmt" {
	subnet_id	= aws_subnet.mgmt.id
	private_ips	= ["10.10.0.100"]
	source_dest_check	= false
	
	tags 			= {
		Name 		= "netropy_mgmt"
	}
}

resource "aws_network_interface" "netropy_app" {
	subnet_id		= aws_subnet.application.id
	private_ips		= ["10.10.1.100"]
	source_dest_check	= false
		
	tags 			= {
		Name 		= "netropy_app"
	}
}

resource "aws_network_interface" "netropy_netropy" {
	subnet_id		= aws_subnet.netropy.id
	private_ips		= ["10.10.2.100"]
	source_dest_check	= false
		
	tags 			= {
		Name 		= "netropy_netropy"
	}
}

resource "aws_eip" "netropy_mgmt" {
	vpc			= true
	network_interface	= aws_network_interface.netropy_mgmt.id
}

resource "aws_eip" "application1" {
	vpc		= true
	instance	= aws_instance.application1.id
}

resource "aws_eip" "application2" {
	vpc		= true
	instance	= aws_instance.application2.id
}

output "netropy_id" {
  value = aws_instance.netropy.id
}