resource "aws_eks_cluster" "main" {
  name     = "my-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [ aws_subnet.subnet["app1"].id, aws_subnet.subnet["app2"].id ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [ aws_subnet.subnet["app1"].id, aws_subnet.subnet["app2"].id ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3a.small"]

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.registry_policy
  ]
}


resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn  = data.aws_caller_identity.current.arn
        username = "admin"
        groups   = [
          "system:masters"
        ]
      }
    ])
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.ng
  ]
}

data "aws_eks_cluster_auth" "token" {
  name = aws_eks_cluster.main.name
  depends_on = [ aws_eks_cluster.main ]
}

data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.token.token
}

resource "kubernetes_service" "nextjs" {
  metadata {
    name      = "nextjs-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "nextjs-app"
    }

    type = "ClusterIP"

    port {
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress_v1" "nextjs" {
  metadata {
    name      = "nextjs-ingress"
    namespace = "default"

    annotations = {
      "kubernetes.io/ingress.class"                         = "alb"
      "alb.ingress.kubernetes.io/scheme"                    = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"              = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/certificate-arn"           = data.aws_acm_certificate.alb_cert.arn
      "alb.ingress.kubernetes.io/ssl-redirect"              = "443"
      "alb.ingress.kubernetes.io/target-type"               = "ip"
      "external-dns.alpha.kubernetes.io/hostname"           = "www.1bean.shop"
    }
  }

  spec {
    tls {
      hosts      = ["www.1bean.shop"]
      secret_name = "dummy-placeholder"  # ACM 사용 시 실제 secret은 필요 없음
    }

    rule {
      host = "www.1bean.shop"

      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "nextjs-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# 2. IAM Policy 가져오기
data "http" "alb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_ingress_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = jsonencode(jsondecode(data.http.alb_controller_policy.response_body))
}

# 3. IAM Role for ServiceAccount
resource "aws_iam_role" "alb_ingress_controller" {
  name = "eks-alb-ingress-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_ingress_controller.name
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
}

# 4. Kubernetes ServiceAccount 생성
resource "kubernetes_service_account" "alb" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller.arn
    }
  }
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
    }
  }
}

# 5. Helm Chart로 ALB Controller 설치
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version = "1.7.1"

  timeout    = 600  # ← 10분까지 대기

  atomic = true

  set {
    name  = "vpcId"
    value = aws_vpc.vpc.id
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb.metadata[0].name
  }

  depends_on = [
    null_resource.update_kubeconfig,
    aws_eks_cluster.main,
    aws_eks_node_group.ng,
    kubernetes_service_account.alb,
    kubernetes_config_map_v1_data.aws_auth,
    null_resource.wait_for_eks_endpoint
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.13.1" # 최신 확인 필요
  
  timeout = 600

  set {
    name  = "aws.zoneIdFilters[0]"
    value = data.aws_route53_zone.public.zone_id
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "policy"
    value = "upsert-only"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.external_dns.metadata[0].name
  }

  set {
    name  = "txtOwnerId"
    value = "external-dns-${aws_eks_cluster.main.name}"
  }

  depends_on = [
    null_resource.update_kubeconfig,
    aws_eks_cluster.main,
    aws_eks_node_group.ng,
    kubernetes_service_account.alb,
    kubernetes_config_map_v1_data.aws_auth,
    null_resource.wait_for_eks_endpoint
  ]
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd2b066"] # AWS 기본 CA thumbprint
}

resource "null_resource" "wait_for_eks_endpoint" {
  provisioner "local-exec" {
    command = <<-EOT
      $endpoint = "${aws_eks_cluster.main.endpoint}".Replace("https://", "")
      Write-Host "🔍 Waiting for EKS endpoint to resolve: $endpoint"

      for ($i = 0; $i -lt 30; $i++) {
        $dns = Resolve-DnsName -Name $endpoint -ErrorAction SilentlyContinue
        if ($dns) {
          Write-Host "✅ EKS endpoint resolved successfully!"
          exit 0
        } else {
          Write-Host "⏳ Waiting... ($i/30)"
          Start-Sleep -Seconds 10
        }
      }

      Write-Error "❌ Timed out waiting for EKS endpoint to resolve."
      exit 1
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    aws_eks_cluster.main
  ]
}

resource "kubernetes_deployment" "nextjs" {
  metadata {
    name      = "nextjs-app"
    namespace = "default"
    labels = {
      app = "nextjs-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nextjs-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "nextjs-app"
        }
      }

      spec {
        container {
          name  = "nextjs"
          image = "docker.io/wonbinjung/nextjs-app:latest"  # ❗ 실제 이미지 명시
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name my-eks --region ap-northeast-2"
    interpreter = ["PowerShell", "-Command"]  # Windows 환경
  }

  depends_on = [aws_eks_cluster.main]
}

resource "null_resource" "remove_kubeconfig" {
  provisioner "local-exec" {
    when    = destroy
    command = "Remove-Item -Path \"$env:USERPROFILE\\.kube\\config\" -Force"
    interpreter = ["PowerShell", "-Command"]
  }

  triggers = {
    always_run = timestamp()
  }
}