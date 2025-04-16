#!/bin/bash
    set -e

    # 헬스체크 폴더 및 응답 준비 -> (* 수정 : ALB 유예시간 늘려서 CodeDeploy단계의 next가 실행되기 까지 대기하는 방식으로 변경)

    # count=0
    # while sudo fuser /var/run/yum.pid >/dev/null 2>&1; do
    #   echo "yum 잠금 대기 중..."
    #   sleep 3
    #   count=$((count+1))
    #   if [ $count -ge 30 ]; then
    #     echo "yum 락 대기 시간 초과. 종료"
    #     exit 1
    #   fi
    # done
    # yum update -y

    # yum install -y python3

    # mkdir -p /home/ec2-user/healthcheck
    # echo "<div>Health Check OK</div>" > /home/ec2-user/healthcheck/index.html

    # cd /home/ec2-user/healthcheck

    # 포트 80에서 응답 시작 (ALB 헬스체크 대응용)
    # nohup python3 -m http.server 80 > /dev/null 2>&1 &
    yum update -y

    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    mkdir -p /home/ec2-user/.docker/cli-plugins/
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /home/ec2-user/.docker/cli-plugins/docker-compose
    chmod +x /home/ec2-user/.docker/cli-plugins/docker-compose
    chown -R ec2-user:ec2-user /home/ec2-user/.docker


    # CodeDeploy Agent 설치
    yum install -y ruby wget
    cd /home/ec2-user
    wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto
    systemctl start codedeploy-agent


