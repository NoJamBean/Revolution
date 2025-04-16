# Dockerfile to build Lambda Layer zip containing requests and aws-requests-auth

# Use an official Python runtime as a parent image
# Lambda 런타임과 일치하는 Python 버전 사용 (예: 3.9)
FROM python:3.9-slim

# Install zip utility
# zip 유틸리티 설치 (zip 압축을 위해 필요)
RUN apt-get update && apt-get install -y zip --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Set the working directory
# 작업 디렉토리 설정
WORKDIR /layer

# Create the directory structure required by Lambda Layers for Python
# Lambda Layer 가 요구하는 디렉토리 구조 생성
RUN mkdir -p python

# Install dependencies into the target directory
# 필요한 Python 라이브러리를 생성된 python 디렉토리에 설치
# requirements.txt 를 사용할 수도 있습니다. 예: COPY requirements.txt . && pip install -r requirements.txt -t python/
RUN pip install requests aws-requests-auth -t python/ --no-cache-dir

# Zip the contents of the python directory
# python 디렉토리의 내용을 zip 파일로 압축
# 작업 디렉토리(/layer)에서 실행하여 zip 파일 내에 python/ 폴더가 포함되도록 함
RUN zip -r /lambda_layer.zip python

# ---- 최종 단계 (선택적) ----
# 빌드된 zip 파일만 포함하는 작은 이미지를 원할 경우 사용
# FROM scratch
# COPY --from=builder /lambda_layer.zip /lambda_layer.zip
# CMD ["/lambda_layer.zip"] # CMD는 의미 없을 수 있음

# docker build -t lambda-layer-builder .
# docker create --name lambda-layer-container lambda-layer-builder
# docker cp lambda-layer-container:/lambda_layer.zip .
# docker rm lambda-layer-container
# docker rmi lambda-layer-builder
# mv lambda_layer.zip /