# Dockerfile to build Lambda Layer zip containing requests and aws-requests-auth
# Excludes boto3 and botocore as they are included in the Lambda runtime

# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Install zip utility
RUN apt-get update && apt-get install -y zip --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /layer

# Create the directory structure required by Lambda Layers for Python
RUN mkdir -p python

# Install dependencies into the target directory
RUN pip install requests aws-requests-auth -t python/ --no-cache-dir

# --- 추가된 부분: Lambda 런타임에 포함된 라이브러리 제거 ---
# Remove boto3 and botocore directories as they are provided by the Lambda runtime
RUN rm -rf python/boto3 python/botocore
# --- 여기까지 ---

# Zip the contents of the python directory
RUN zip -r /lambda_layer.zip python

# docker build -t lambda-layer-builder .
# docker create --name lambda-layer-container lambda-layer-builder
# docker cp lambda-layer-container:/lambda_layer.zip .
# docker rm lambda-layer-container
# docker rmi lambda-layer-builder
# mv lambda_layer.zip /