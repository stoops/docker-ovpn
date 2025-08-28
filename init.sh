#!/bin/bash

apt update && apt upgrade -y
apt install -y openvpn openssh-server iptables lsof vim git gcc net-tools apache2-utils
apt install -y autoconf libtool pkg-config make libnl-genl-3-dev libcap-ng-dev libssl-dev libpam0g-dev

mkdir -p /var/run/sshd
echo 'root:toor' | chpasswd
sed -e 's@^.*PermitRootLogin.*$@PermitRootLogin yes@ig' -i /etc/ssh/sshd_config
sed -e 's@session.*required.*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

mkdir -p /opt
cd /app/src
autoreconf -vif ; ./configure --disable-lzo --disable-lz4 && touch .gitignore .gitattributes && make
cp -fv /app/src/src/openvpn/openvpn /opt/

cp -frv /app/pki /opt/
chmod 700 /opt/pki/*
