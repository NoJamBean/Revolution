# Ubuntu 22.04 베이스 이미지 사용
FROM ubuntu:22.04

# 컨테이너 안에서 작업할 디렉토리 지정
WORKDIR /app

# 필수 패키지 설치 및 Node.js 18 설치
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

# yarn 설치 (선택사항: npm 대신 yarn 사용 시)
RUN npm install -g yarn

# 의존성 설치용 파일 복사
COPY package.json yarn.lock ./

# 의존성 설치
RUN yarn install

# 소스 코드 전체 복사
COPY . .

# Next.js 빌드
RUN yarn build

# 애플리케이션이 사용하는 포트 오픈
EXPOSE 3000

# 컨테이너 시작 시 실행할 명령어
CMD ["yarn", "start"]
