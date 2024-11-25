# IAM Policy for ALB Ingress Controller
data "aws_iam_policy_document" "alb_policy" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteSecurityGroup",
      "ec2:GetSecurityGroupsForVpc",
      "elasticloadbalancing:*",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:PassRole",
      "waf-regional:*",
      "wafv2:*",
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "tag:GetResources",
      "tag:TagResources"
    ]

    resources = ["*"]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "alb_ingress_controller" {
  name = "${var.cluster_name}-alb-ingress-controller-policy"

  policy = data.aws_iam_policy_document.alb_policy.json
}

# OIDC Provider for EKS
data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# IAM Role for ALB Ingress Controller Service Account
resource "aws_iam_role" "alb_ingress_service_account" {
  name = "${var.cluster_name}-alb-ingress-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy_attachment" {
  role       = aws_iam_role.alb_ingress_service_account.name
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
}

# Kubernetes Service Account for ALB Ingress Controller
resource "kubernetes_service_account" "alb_ingress_service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_service_account.arn
    }
  }
}

# Deploy ALB Ingress Controller using Helm
resource "helm_release" "alb_ingress_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = var.alb_ingress_chart_version
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.aws_region
      vpcId       = aws_vpc.eks_vpc.id
      "ingressClassConfig.default" = true
      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }
    })
  ]
}
