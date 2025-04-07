#!/bin/bash

# IP 포워딩 활성화
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# NAT 마스커레이딩 설정
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE