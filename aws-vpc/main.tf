resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        name = "${var.common_tags}vpc"
    }
    instance_tenancy = "default"
    enable_dns_hostnames = true

  
}


# aws custom vpc creation tags
/*
1. selecect the region
2.create vpc
3.enable dns host name in the vpc
4.create internet gateway
5.attach internet gateway to vpc
6.create public subnet
7.enable auto assign pubblic ip setting
8.create public route table
9.add public route table to public route table
10. associate public route table to public subnet
11. create an private subnet
12.create nat gateway in public subnets
13.
*/


resource "aws_internet_gateway" "vpc-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "${var.common_tags} gateway"
  }

}


resource "aws_subnet" "public-vpc-subnet" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = " ${var.common_tags} publice subnet"
  }
  availability_zone = var.aws_zone
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

}


resource "aws_route_table" "public-vpc-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "${var.common_tags} route table"

  }
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-gateway.id
  }
}


resource "aws_route_table_association" "public-subnet-route-table-association" {
    subnet_id = aws_subnet.public-vpc-subnet.id
    route_table_id = aws_route_table.public-vpc-route-table.id
  
}
/*
resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.aws_zone
  map_public_ip_on_launch = false
  tags = {
    name = "${var.common_tags} private subnet"
  }

}
*/

# nat gateway creation
###################################################################################################################################
#                                           NAT GATE WAY
###################################################################################################################################
resource "aws_eip" "eip_gatway" {
    vpc= true
    tags = {
      name= "eip1"
    }
  
}
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip_gatway.id
  subnet_id = aws_subnet.public-vpc-subnet.id

  tags = {
    name = "nat1"
  }
}

##########################################################################################################################################


# private subnet
resource "aws_subnet" "private-app-subnet-1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.aws_zone
  map_public_ip_on_launch = false
  tags = {
    name = "private_subnet_App tier"
  }
}



## route table for both the app and database  private subnet
#####################################################################################
#                        ROUTE TABLE
####################################################################################
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route = {
            cidr_block = "0.0.0.0/0"
            aws_nat_gateway = aws_nat_gateway.nat1.id
  }

  tags = {
    name = "private route table"
  }
}


#######################################################################################


## route table association for the app subnet
resource "aws_route_table_association" "private-app-subnet-route-table-association" {
  subnet_id = aws_subnet.private-app-subnet-1.id
  route_table_id = aws_route_table.private_route_table.id
}

#private subnet for database
resource "aws_subnet" "private-database-subnet-1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.aws_zone
  map_public_ip_on_launch = false
  tags = {
    name = "private_subnet_database_tier"
  }
}

# route table association for the database subnet
resource "aws_route_table_association" "private-database-subnet-route-table-association" {
  subnet_id = aws_subnet.private-database-subnet-1.id
  route_table_id = aws_route_table.private_route_table.id
}

