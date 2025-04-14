# 1. IAM 역할 생성
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




# IAM 역할 생성 - Web용 EC2의 권한
resource "aws_iam_role" "ec2_role" {
  name = "EC2InstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
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





# CodeBuild 정책 생성
# resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
#   role       = aws_iam_role.codebuild_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
# }


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

resource "aws_iam_policy_attachment" "attach_codebuild_s3_read_policy" {
  name       = "attach-codebuild-s3-read"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.codebuild_s3_read_policy.arn
}





# CodeDeploy 정책 생성
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}





# Web-EC2용 정책 생성
resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# Web용 EC2 프로파일 생성 (추후 EC2에 부착하기 위함)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
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

resource "aws_iam_policy_attachment" "attach_codepipeline_s3_policy" {
  name       = "attach-codepipeline-s3"
  roles      = [aws_iam_role.codepipeline_role.name] # 형님의 CodePipeline 실행 역할
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
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


resource "aws_iam_policy_attachment" "attach_codepipeline_codebuild_policy" {
  name       = "attach-codepipeline-codebuild"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.codepipeline_codebuild_policy.arn
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

resource "aws_iam_policy_attachment" "attach_codebuild_logs_policy" {
  name       = "attach-codebuild-cloudwatch-logs"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
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
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:ListAllMyBuckets"
        ]
        Resource = [
          "arn:aws:s3:::*/*", # 모든 S3 객체에 대한 접근
          "arn:aws:s3:::*"    # 모든 S3 버킷에 대한 접근
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "s3-full-access-attachment"
  roles      = [aws_iam_role.ec2_s3_role.name]
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

# 3. IAM 인스턴스 프로파일 생성 (EC2에 연결하기 위함)
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_role.name
}


# resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
#   role       = aws_iam_role.ec2_s3_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }
