module "kubernetes-terraform-ec2-example" {
  source = "../../kubernetes-terraform-ec2-example"

  aws_region = "ap-southeast-2"
  controller_aws_region = "ap-southeast-2"
  controller_ec2_instance_type = "t2.medium"
}