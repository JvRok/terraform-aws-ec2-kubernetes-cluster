# AWS Provider to begin
provider "aws" {
  region = var.aws_region
}

module "controller-node" {
  source = "./modules/controller-node"

  aws_region = var.aws_region
  ec2_instance_type = var.controller_ec2_instance_type
  subnet_id = var.controller_subnet_id
}