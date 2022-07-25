#The region this is all taking place
variable "aws_region" {
  description = "Region for AWS provider to operate in"
  default     = "ap-southeast-2"
}

variable "controller_aws_region" {
  description = "Controller AWS region"
  default     = "ap-southeast-2"
}

variable "controller_ec2_instance_type" {
  description = "type of EC2 instance to provision for controller."
  default     = "t2.medium"
  nullable    = false
}

variable "ssh_keyname" {
  description = "Public key to allow ssh onto server"
}

variable "k8s_vpc_cidr_block" {
  description = "K8s vpc cidr block"
  default     = "10.0.0.0/16"
}

variable "controller_cidr_block" {
  description = "K8s controller subnet cidr block"
  default     = "10.0.1.0/24"
}

variable "worker_node_cidr_block_1" {
  description = "K8s worker subnet 1 cidr block"
  default     = "10.0.2.0/24"
}

variable "controller_az_1" {
  description = "The AZ the controller node should reside on"
  default     = "ap-southeast-2a"
}

variable "worker_az_1" {
  description = "The AZ the controller node should reside on"
  default     = "ap-southeast-2b"
}

variable "worker_az_2" {
  description = "The AZ the controller node should reside on"
  default     = "ap-southeast-2c"
}
