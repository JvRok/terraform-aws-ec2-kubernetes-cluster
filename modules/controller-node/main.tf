data "aws_ami" "os" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"] #Could be a variable, unnecessary in this example
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] #64 bit only
  }

  owners = ["${var.ami_owner}"]
}

resource "aws_instance" "kubernetes-controller" {
  ami               = data.aws_ami.os.id
  instance_type     = var.ec2_instance_type
  subnet_id         = var.subnet_id
  associate_public_ip_address = false           #Controller doesn't need a public IP
  tags              = {
                        Name = var.name
                      }
}