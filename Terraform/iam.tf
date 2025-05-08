resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_user" "logicapp_s3_user" {
  name = "logicapp-s3-user"
}

resource "aws_iam_access_key" "logicapp_key" {
  user = aws_iam_user.logicapp_s3_user.name
}

resource "aws_iam_role" "api_server_role" {
  name = "api_server_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role" "rds_to_cwlogs" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "s3_replication_role" {
  name = "s3_replication_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_fullaccess_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "websocket_role" {
  name = "websocket_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM 역할 생성 - CodeBuild의 권한
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}




# IAM 역할 생성 - CodeDeploy의 권한
resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}




# IAM 역할 생성 - CodePipeline의 권한
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })


  tags = {
    Name        = "CodePipelineExecutionRole"
    Environment = "dev"
  }
}

//Policy
resource "aws_iam_policy" "logicapp_s3_policy" {
  name        = "LogicAppS3PutPolicy"
  description = "Allow Logic Apps to put objects into logs bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:PutObject"]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::${aws_s3_bucket.long_user_data_bucket.bucket}/*"
    }]
  })
}

# CodeBuild S3 접근 허용
resource "aws_iam_policy" "codebuild_s3_read_policy" {
  name        = "CodeBuildS3ReadAccess"
  description = "Grants CodeBuild permission to read source from S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::webdeploy-artifact-bucket",
          "arn:aws:s3:::webdeploy-artifact-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "cognito_user_mgmt" {
  name        = "CognitoUserManagementPolicy"
  description = "Allow Cognito user creation"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "cognito-idp:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodeDeploy 정책 생성 (커스텀)
resource "aws_iam_policy" "codedeploy_autoscaling_custom" {
  name = "CodeDeployASGCustomPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:*",
          "iam:PassRole",
          "iam:GetRole",
          "ec2:*",
          "elasticloadbalancing:*",
          "codedeploy:*"
          # "autoscaling:CreateAutoScalingGroup",
          # "autoscaling:UpdateAutoScalingGroup",
          # "autoscaling:DeleteAutoScalingGroup",
          # "autoscaling:CreateOrUpdateTags",
          # "autoscaling:DescribeAutoScalingGroups"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodePipeline용 정책 생성 및 부착 (커스텀 정책)

# CodePipeline S3 접근 허용
resource "aws_iam_policy" "codepipeline_s3_policy" {
  name        = "CodePipelineS3Access"
  description = "Grants CodePipeline access to the S3 artifact bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::webdeploy-artifact-bucket",
          "arn:aws:s3:::webdeploy-artifact-bucket/*"
        ]
      }
    ]
  })
}

# CodePipeline -> CodeBuild 실행 및 흐름추적 허용
resource "aws_iam_policy" "codepipeline_codebuild_policy" {
  name        = "CodePipelineCodeBuildAccess"
  description = "Allows CodePipeline to start any CodeBuild project"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = "arn:aws:codebuild:ap-northeast-2:248189921892:project/*"
      }
    ]
  })
}


# CodePipeline -> Cloudwatch 로그 권한 허용
resource "aws_iam_policy" "codebuild_logs_policy" {
  name        = "CodeBuildCloudWatchLogsAccess"
  description = "Allows CodeBuild to write logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:ap-northeast-2:248189921892:log-group:/aws/codebuild/*"
      }
    ]
  })
}

# CodePipeline -> CodeDeploy 배포 생성 권한 
resource "aws_iam_policy" "codepipeline_codedeploy_policy" {
  name        = "CodePipelineCodeDeployAccess"
  description = "Allow CodePipeline to trigger CodeDeploy deployment"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_use_connection" {
  name = "codepipeline-use-connection"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "codestar-connections:UseConnection",
        Resource = "arn:aws:codeconnections:us-east-1:248189921892:connection/f58fa5ca-9f80-4c75-b270-e1db80975efd"
      }
    ]
  })
}

# 2. S3 Full Access 정책 생성 - EC2용 
resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Allows full access to all S3 buckets and objects"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::*/*", # 모든 S3 객체에 대한 접근
          "arn:aws:s3:::*"    # 모든 S3 버킷에 대한 접근
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_ssm_policy" {
  name        = "EC2SSMPolicy"
  description = "Policy to allow EC2 instances to communicate with Systems Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ssm:*"
        ]
        Resource = "*"
      }
    ]
  })
}

#Attachment
resource "aws_iam_user_policy_attachment" "attach" {
  user       = aws_iam_user.logicapp_s3_user.name
  policy_arn = aws_iam_policy.logicapp_s3_policy.arn
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "s3-full-access-attachment"
  roles      = [aws_iam_role.ec2_s3_role.name, aws_iam_role.api_server_role.name]
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

resource "aws_iam_policy_attachment" "attach_codepipeline_codebuild_policy" {
  name       = "attach-codepipeline-codebuild"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.codepipeline_codebuild_policy.arn
}

resource "aws_iam_policy_attachment" "attach_codepipeline_s3_policy" {
  name       = "attach-codepipeline-s3"
  roles      = [aws_iam_role.codepipeline_role.name] # 형님의 CodePipeline 실행 역할
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
}

resource "aws_iam_policy_attachment" "attach_codebuild_s3_read_policy" {
  name       = "attach-codebuild-s3-read"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.codebuild_s3_read_policy.arn
}

resource "aws_iam_policy_attachment" "attach_codebuild_logs_policy" {
  name       = "attach-codebuild-cloudwatch-logs"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "codedeploy_autoscaling_custom_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = aws_iam_policy.codedeploy_autoscaling_custom.arn
}

# CodeDeploy 정책 생성
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "codedeploy_s3_policy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

# CodePipeline용 정책 생성 및 부착
resource "aws_iam_role_policy_attachment" "codepipeline_fullaccess" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_codestar_connection" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeStarFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_codedeploy_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codedeploy_policy.arn
}

# CodeDeploy용 권한 attach
resource "aws_iam_role_policy_attachment" "ec2_codedeploy_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_to_api_server_role_cognito" {
  role       = aws_iam_role.api_server_role.name
  policy_arn = aws_iam_policy.cognito_user_mgmt.arn
}

resource "aws_iam_role_policy_attachment" "attach_to_api_server_role_s3" {
  role       = aws_iam_role.api_server_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "rds_logs" {
  role       = aws_iam_role.rds_to_cwlogs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.rds_to_cwlogs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role_policy_attachment" "websocket_s3" {
  role       = aws_iam_role.websocket_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_replica" {
  role       = aws_iam_role.s3_replication_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

#Profile
resource "aws_iam_instance_profile" "api_server_profile" {
  name = "api_server_profile"
  role = aws_iam_role.api_server_role.name
}

resource "aws_iam_instance_profile" "websocket_profile" {
  name = "websocket_profile"
  role = aws_iam_role.websocket_role.name
}

# Web용 EC2 프로파일 생성 (추후 EC2에 부착하기 위함)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_s3_role.name
}
