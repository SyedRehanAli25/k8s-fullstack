output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.cluster.name} --region ${var.region}"
}

output "tf_state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}
