variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "shop-eks-cluster"
}

variable "node_group_instance_type" {
  description = "Instance type for EKS node group"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "alb_ingress_chart_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.5.4"
}

variable "shop_name" {
  description = "Shop name for the application"
  type        = string
  default     = "example-shop"
}

variable "example_shop_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS on the example-shop"
  type        = string
  default     = "arn:aws:acm:us-east-1:242201315252:certificate/ef962d68-06d3-4f9d-80f4-dc8af2036540"
}

variable "base_dns_zone_name" {
    description = "Base DNS zone name for the app DNS"
    type        = string
    default     = "i3.devops.antimatter.io"
}