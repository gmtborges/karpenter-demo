data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../eks/terraform.tfstate"
  }
}

data "aws_security_group" "eks_sg" {
  id = data.terraform_remote_state.eks.outputs.eks_sg_id
}

import {
  to = aws_security_group.eks_sg_update
  id = data.terraform_remote_state.eks.outputs.eks_sg_id
}

resource "aws_security_group" "eks_sg_update" {
  name        = data.aws_security_group.eks_sg.name
  description = data.aws_security_group.eks_sg.description
  vpc_id      = data.aws_security_group.eks_sg.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  tags = merge(
    data.aws_security_group.eks_sg.tags,
    {
      "karpenter.sh/discovery" = data.terraform_remote_state.eks.outputs.eks_name
    }
  )
}
