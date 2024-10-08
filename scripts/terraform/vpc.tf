#
# Creates a vpc on AWS.
#

resource "aws_vpc" "sit722week10"{
    cidr_block = "10.0.0.0/16"
    tags = {
         ResourceGroupName = var.resource_group_name
    }
}

# Fetch available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

#
# Creates a public subnets under the vpc on AWS.
#

resource "aws_subnet" "publicsubnet"{
    vpc_id = aws_vpc.sit722week10.id
    count = 2
    cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index + 1)
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
    map_public_ip_on_launch = true
    tags = {
         ResourceGroupName = var.resource_group_name
    }
}

#
# Creates a private subnets under the vpc on AWS.
#

resource "aws_subnet" "privatesubnet"{
    vpc_id = aws_vpc.sit722week10.id
    count = 2
    cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index + 10)
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
    map_public_ip_on_launch = false
    tags = {
         ResourceGroupName = var.resource_group_name
    }
}

#
# Creates an internet gateway under the vpc on AWS.
#

resource "aws_internet_gateway" "sit722week10igw"{
    vpc_id = aws_vpc.sit722week10.id
    tags = {
         ResourceGroupName = var.resource_group_name
    }
}

#
# Creates a public route table under the vpc on AWS.
#

resource "aws_route_table" "publicrt"{
    vpc_id = aws_vpc.sit722week10.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.sit722week10igw.id
    }
    tags = {
         ResourceGroupName = var.resource_group_name
    }
}

#
# Creates a route table association public subnet under the vpc on AWS.
#

resource "aws_route_table_association" "publicrtassociation"{
    subnet_id = aws_subnet.publicsubnet[0].id
    route_table_id = aws_route_table.publicrt.id
}

# Output public subnet id

output "public_subnet_ids" {
  value = aws_subnet.publicsubnet[*].id
}
 