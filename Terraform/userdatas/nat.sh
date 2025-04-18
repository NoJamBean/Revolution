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

    location / {
        proxy_pass http://api.backend.internal;
    }
}
EOL

sudo systemctl restart nginx