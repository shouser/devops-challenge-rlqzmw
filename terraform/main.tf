# Helm Release for example app
resource "helm_release" "example_app" {
  name       = "example-app"
  chart      = "../helm-chart"
  namespace  = "default"

  values = [
    yamlencode({
      replicaCount = 1
      image = {
        repository = "immesys/example-app"
        tag        = "latest"
        pullPolicy = "IfNotPresent"
      }
      shopName = var.shop_name
      service = {
        type = "ClusterIP"
        port = 80
      }
      ingress = {
        enabled = true
        annotations = {
          "alb.ingress.kubernetes.io/scheme"   = "internet-facing"
          "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/certificate-arn" = var.example_shop_certificate_arn
          "alb.ingress.kubernetes.io/target-type" = "ip"
        }
        hosts = [{
          host = "${var.shop_name}.${var.base_dns_zone_name}"
          paths = [{
            path = "/"
            pathType = "ImplementationSpecific"
          }]
        }]
      }
    })
  ]
}

data "kubernetes_ingress_v1" "example_app" {
  metadata {
    name      = "example-app"
    namespace = helm_release.example_app.metadata[0].namespace
  }
}

# Route53 DNS for example app
resource "aws_route53_record" "dns_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.shop_name}.${var.base_dns_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_ingress_v1.example_app.status[0].load_balancer[0].ingress[0].hostname]
}

data "aws_route53_zone" "main" {
  name = var.base_dns_zone_name
}
