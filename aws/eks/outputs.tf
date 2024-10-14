output "eks_name" {
  value = aws_eks_cluster.my_eks.name
}

output "eks_sg_id" {
  value = aws_eks_cluster.my_eks.vpc_config[0].cluster_security_group_id
}

output "eks_endpoint" {
  value = aws_eks_cluster.my_eks.endpoint
}

output "karpenter_node_role_arn" {
  value = aws_iam_role.karpenter_node_role.arn
}
