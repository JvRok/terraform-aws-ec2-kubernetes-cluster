#The region this is all taking place
variable "aws_region" {
  description = "Region for AWS provider to operate in"
  default = "ap-southeast-2"
}

variable "controller_aws_region" {
  description = "Controller AWS region"
  default = "ap-southeast-2"
}

variable "controller_subnet_id" {
  description = "The subnet of the main controller node"
}

variable "controller_ec2_instance_type" {
  description = "type of EC2 instance to provision for controller."
  default = "t2.medium"
  nullable = false
}

variable "ssh_keyname" {
  description = "Public key to allow ssh onto server"
}
