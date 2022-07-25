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

data "template_file" "k8s_controller_script" {
  template = "${file("${path.module}/bootstrap/kubernetes-master-setup.sh")}"

  vars = {
    init_token = var.join_tokenid
  }

}

#Create controller AWS security groups. 
#Will create: 
#1. Ingress for Worker Nodes to Kubernetes Controller
#2. Egress from Kubernetes Controller to Worker Nodes
#3. SSH from WORLD to Kubernetes --- This is only as this is a TEST CLUSTER. Else this would be a bad idea.

resource "aws_security_group_rule" "k8s_controlplane_ssh_entry" {
  type              = "ingress"
  description       = "SSH from PC for remote Sysadmining"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = var.k8s_controller_node_sg
  cidr_blocks       = ["0.0.0.0/0"]
}

#ingress workers
resource "aws_security_group_rule" "k8s_controlplane_controller_api" {
  type                     = "ingress"
  description              = "API Server port"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = var.k8s_controller_node_sg
  source_security_group_id = var.k8s_worker_nodes_sg

}

#ingress workers
resource "aws_security_group_rule" "k8s_controlplane_nodeport_entry" {
  type                     = "ingress"
  description              = "Nodeport Ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = var.k8s_controller_node_sg
  source_security_group_id = var.k8s_worker_nodes_sg
}

# Allow outgoing connectivity
resource "aws_security_group_rule" "controller_outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.k8s_controller_node_sg
}

# Allow outgoing connectivity
resource "aws_security_group_rule" "controller_https_outbound" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.k8s_controller_node_sg
}


resource "aws_security_group_rule" "k8s_controlplane_to_api" {
  type                     = "egress"
  description              = "Controller to worker node"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = var.k8s_controller_node_sg
  source_security_group_id = var.k8s_worker_nodes_sg
}

resource "aws_security_group_rule" "k8s_controlplane_nodeport" {
  type                     = "egress"
  description              = "Node port IPs"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = var.k8s_controller_node_sg
  source_security_group_id = var.k8s_worker_nodes_sg
}

resource "aws_instance" "kubernetes-controller" {
  ami                         = data.aws_ami.os.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.k8s_subnet_id
  key_name                    = var.ssh_keyname
  associate_public_ip_address = true           #Controller doesn't need a public IP
  tags                        = { Name = var.name }
  user_data                   = data.template_file.k8s_controller_script.rendered
  vpc_security_group_ids      = [var.k8s_controller_node_sg]

  #Size/type of os disk
  #At this point will keep it to single disk/small to save complexity
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
  }
}

output "endpointip" {
  value = aws_instance.kubernetes-controller.private_ip
}