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


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

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

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
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

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 3000
    }
  }
}