# AWS Provider to begin
provider "aws" {
  region = var.aws_region
}

locals {
  tokenid = "${substr(random_string.k8s_join_string.result, 0, 6)}.${substr(random_string.k8s_join_string.result, -16, 0)}"
}

#Create random token key for K8s and workers to use
resource "random_string" "k8s_join_string" {
  length  = 22
  special = false
  upper   = false
}

#Create VPC for application
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.k8s_vpc_cidr_block
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "k8s_vpc"
  }
}

resource "aws_internet_gateway" "k8s_gw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s gateway"
  }
}

resource "aws_default_route_table" "k8s_route_table" {
  default_route_table_id = aws_vpc.k8s_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_gw.id
  }

  tags = {
    Name = "default_k8s_route_table"
  }
}

resource "aws_subnet" "controller_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.controller_cidr_block
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.controller_az_1
  tags = {
    Name = "controller_subnet"
  }
}

resource "aws_subnet" "worker_subnet_1" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.worker_node_cidr_block_1
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = var.worker_az_1
  tags = {
    Name = "worker_subnet_1"
  }
}

resource "aws_security_group" "k8s_controller_node_sg" {
  name        = "Controller Node Security Group"
  description = "The security group that contains the controller nodes"
  vpc_id      = aws_vpc.k8s_vpc.id
}

#Create the security group for agent nodes
resource "aws_security_group" "k8s_worker_nodes_sg" {
  name        = "Worker Nodes Security Group"
  description = "Worker Nodes Security Group"
  vpc_id      = aws_vpc.k8s_vpc.id
}

module "controller_node" {
  source = "./modules/controller-node"

  aws_region             = var.aws_region
  ec2_instance_type      = var.controller_ec2_instance_type
  ssh_keyname            = var.ssh_keyname
  k8s_vpc_id             = aws_vpc.k8s_vpc.id
  k8s_vpc_cidr_block     = aws_vpc.k8s_vpc.cidr_block
  k8s_subnet_id          = aws_subnet.controller_subnet.id
  k8s_controller_node_sg = aws_security_group.k8s_controller_node_sg.id
  k8s_worker_nodes_sg    = aws_security_group.k8s_worker_nodes_sg.id
  join_tokenid           = local.tokenid

  depends_on = [aws_internet_gateway.k8s_gw]
}

module "worker_node" {
  source = "./modules/worker-node"

  aws_region             = var.aws_region
  ec2_instance_type      = var.controller_ec2_instance_type
  ssh_keyname            = var.ssh_keyname
  k8s_vpc_id             = aws_vpc.k8s_vpc.id
  k8s_vpc_cidr_block     = aws_vpc.k8s_vpc.cidr_block
  k8s_subnet_id          = aws_subnet.worker_subnet_1.id
  k8s_controller_node_sg = aws_security_group.k8s_controller_node_sg.id
  k8s_worker_nodes_sg    = aws_security_group.k8s_worker_nodes_sg.id
  join_tokenid           = local.tokenid
  endpointip             = module.controller_node.endpointip

  depends_on = [module.controller_node]
}