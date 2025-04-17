#!/bin/bash
yum update -y
yum install -y iptables-services
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save
systemctl enable iptables
systemctl start iptables

sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

INSTANCE_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo tee /etc/nginx/conf.d/nginx.conf > /dev/null <<EOL
server {
    listen 80;
    server_name \$INSTANCE_PUBLIC_IP;

    # location / {
    #     proxy_pass http://api.backend.internal;
    #     # proxy_pass_request_headers on;

    #     # CORS 설정 추가
    #     add_header 'Access-Control-Allow-Origin' 'http://localhost:3000' always;
    #     add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
    #     add_header 'Access-Control-Allow-Headers' '*' always;
    #     add_header 'Access-Control-Allow-Credentials' 'true' always; # Credential 허용

    #     # OPTIONS 요청 처리 (Preflight 요청에 응답)
    #     if (\$request_method = OPTIONS) {
    #         add_header 'Access-Control-Allow-Origin' 'http://localhost:3000';
    #         add_header 'Access-Control-Allow-Methods' 'GET, POST';
    #         add_header 'Access-Control-Allow-Headers' '*';
    #         add_header 'Access-Control-Allow-Credentials' 'true';
    #         return 204; # No Content 응답
    #     }
    # }
}
EOL

sudo systemctl restart nginx