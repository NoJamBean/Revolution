#!/bin/bash

# echo "[AfterInstall] 의존성 설치 시작"

# # Node.js 수동 설치
# echo "[AfterInstall] Node.js 18.17.1 설치 중"

# sudo wget -nv https://d3rnber7ry90et.cloudfront.net/linux-x86_64/node-v18.17.1.tar.gz
# sudo mkdir -p /usr/local/lib/node
# sudo tar -xf node-v18.17.1.tar.gz
# sudo mv node-v18.17.1 /usr/local/lib/node/nodejs

# sudo rm -f node-v18.17.1.tar.gz

# export NODEJS_HOME=/usr/local/lib/node/nodejs
# export PATH=$NODEJS_HOME/bin:$PATH

# cat << 'EOF' | sudo tee /etc/profile.d/node.sh > /dev/null
# export NODEJS_HOME=/usr/local/lib/node/nodejs
# export PATH=$NODEJS_HOME/bin:$PATH
# EOF

# sudo chmod +x /etc/profile.d/node.sh


# # 임시코드
# rm -rf /home/ec2-user/.cache/yarn
# yarn cache clean


# # pm2, yarn 설치
# sudo env "PATH=$PATH" npm install -g pm2
# sudo env "PATH=$PATH" npm install -g yarn



# # 📌 이제 프로젝트 폴더로 이동
# cd /home/ec2-user/app

# #ec2-user에게 권한 부여
# sudo chown -R ec2-user:ec2-user /home/ec2-user/app

# # 의존성 설치
# yarn install --frozen-lockfile

# # 배포 스크립트 실행 권한 부여
# sudo chmod +x scripts/*.sh

# echo "[AfterInstall] 완료"


echo "[AfterInstall] Node.js 18.17.1 고정 설치 시작"

# 1. 필수 패키지 설치
sudo apt-get update -y
sudo apt-get install -y curl wget build-essential

# 2. Node.js 18.17.1 바이너리 다운로드 및 설치
NODE_VERSION="v18.17.1"
NODE_DISTRO="linux-x64"
NODE_FILENAME="node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz"
NODE_DIR="/usr/local/lib/nodejs"

sudo mkdir -p $NODE_DIR
cd /tmp
wget -nv "https://nodejs.org/dist/${NODE_VERSION}/${NODE_FILENAME}"
sudo tar -xf ${NODE_FILENAME} -C $NODE_DIR
sudo rm -f ${NODE_FILENAME}

# 3. 환경변수 등록
cat << 'EOF' | sudo tee /etc/profile.d/node.sh > /dev/null
export NODEJS_HOME=/usr/local/lib/nodejs/node-v18.17.1-linux-x64
export PATH=$NODEJS_HOME/bin:$PATH
EOF

sudo chmod +x /etc/profile.d/node.sh
# 현재 쉘에 적용
export NODEJS_HOME=/usr/local/lib/nodejs/node-v18.17.1-linux-x64
export PATH=$NODEJS_HOME/bin:$PATH

echo "[AfterInstall] Node.js 버전: $(node -v)"

# 4. pm2, yarn 전역 설치 (sudo 필요)
sudo npm install -g pm2 yarn

# 5. 프로젝트 폴더로 이동 (환경에 따라 경로 조정)
cd /home/ubuntu/app

# 6. ubuntu 유저에게 권한 부여
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# 7. yarn 캐시 클리어 및 의존성 설치
rm -rf /home/ubuntu/.cache/yarn
yarn cache clean
yarn install --frozen-lockfile

# 8. 배포 스크립트 실행 권한 부여
sudo chmod +x scripts/*.sh

echo "[AfterInstall] 완료"