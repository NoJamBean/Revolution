#!/bin/bash
yum update -y
yum install -y iptables-services
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save
systemctl enable iptables
systemctl start iptables