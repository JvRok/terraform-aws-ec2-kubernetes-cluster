#descriptive name passed to ec2 instance
variable "name" {
  type        = string
  description = "Name to pass on to ec2 name tag"
  default     = "terraform-k8s-controller-node"
  nullable    = false
}

variable "aws_region" {
  description = "AWS region"
}

variable "ec2_instance_type" {
  description = "type of EC2 instance to provision."
}

variable "ami_owner" {
  description = "Listed owner of AMI - defaulted to centos"
  default     = "125523088429"
  nullable    = false
}

variable "ami_name" {
  description = "OS name to filter for when finding AMI ID"
  default     = "CentOS Stream 9*"
  nullable    = false
}

variable "ssh_keyname" {
  description = "SSH key for controller"
}

variable "k8s_vpc_id" {
  description = "the pre-created VPC"
}

variable "k8s_vpc_cidr_block" {
  description = "the cidr block for controller vpc"
}

variable "k8s_subnet_id" {
  description = "Subnet for k8s"
}

variable "k8s_controller_node_sg" {
  description = "Controller node security group"
}

variable "k8s_worker_nodes_sg" {
  description = "Worker node security group"
}

variable "join_tokenid" {
  description = "The token used to init the cluster"
}

variable apiaccess {
  description = "Should apiaccess be enabled (insecure)"
  default = "false"
}

variable "bearer_token_password" {
  description =  "Bearer token password for API Access. Requires apiaccess to be true"
  default = "insecureToken"
}

