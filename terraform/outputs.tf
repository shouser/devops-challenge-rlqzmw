output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "load-balancer-hostname" {
  value = try(data.kubernetes_ingress_v1.example_app.status[0].load_balancer[0].ingress[0].hostname, {})
}