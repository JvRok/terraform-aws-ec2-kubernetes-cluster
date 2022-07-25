#descriptive name passed to ec2 instance
variable "name" {
  type = string
  description = "Name to pass on to ec2 name tag"
  default = "terraform-k8s-controller-node"
  nullable = false
}

variable "aws_region" {
  description = "AWS region"
}

variable "ec2_instance_type" {
  description = "type of EC2 instance to provision."
}

variable "ami_owner" {
  description = "Listed owner of AMI - defaulted to centos"
  default = "125523088429"
  nullable = false
}

variable "ami_name" {
  description = "OS name to filter for when finding AMI ID"
  default = "CentOS Stream 9*"
  nullable = false
}

variable "subnet_id" {
  description = "The subnet of the main controller node"
}

variable ssh_keyname {
  description = "SSH key for controller"
}

