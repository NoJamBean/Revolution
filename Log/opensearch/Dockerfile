FROM python:3.9-slim
# 여기에 원하는 런타임 python 쓰기

RUN apt-get update && apt-get install -y zip --no-install-recommends && rm -rf /var/lib/apt/lists/*

WORKDIR /layer

RUN mkdir -p python

RUN pip install requests aws-requests-auth -t python/ --no-cache-dir 
RUN pip install geoip2 -t python/ --no-cache-dir
# 여기에 레이어로 넣을 라이브러리 pip로 python/경로에 설치

RUN rm -rf python/boto3 python/botocore

RUN zip -r /lambda_layer.zip python

# docker build -t lambda-layer-builder .
# docker create --name lambda-layer-container lambda-layer-builder
# docker cp lambda-layer-container:/lambda_layer.zip .
# docker rm lambda-layer-container
# docker rmi lambda-layer-builder