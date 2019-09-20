#!/bin/bash

user=''
password=''
ip=`wget -t 3 -T 15 -qO- http://ipv4.icanhazip.com`

if [ -n $user ];then
    user='vpnuser'
fi

if [ -n $password ];then
    password='helloworld@123'
fi

yum install -y pptpd ppp pptp-setup

cat << EOF >> /etc/pptpd.conf

localip 192.168.0.1
remoteip 192.168.0.100-105

EOF

echo "$user pptpd $password *" >> /etc/ppp/chap-secrets

cat << EOF >> /etc/ppp/options.pptpd

ms-dns 8.8.8.8
ms-dns 8.8.4.4

EOF

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -s 192.168.0.1/24 -o eth0 -j MASQUERADE
iptables -A INPUT -p UDP --dport 53 -j ACCEPT
iptables -A INPUT -p TCP --dport 1723 -j ACCEPT
iptables -A INPUT -p TCP --dport 47 -j ACCEPT
iptables -A INPUT -p gre -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.0.1/24 -j SNAT --to-source 165.23.31.11
iptables-save > ./iptables.conf

systemctl enable pptpd
systemctl start pptpd

echo "=========================="
echo -e "\n\n"

cat << EOF
your username : $user
your password : $password
your ip : $ip
EOF



echo -e "\n\n"
echo "=========================="

