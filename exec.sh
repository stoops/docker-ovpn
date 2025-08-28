#!/bin/bash

/usr/sbin/sshd

cat >/etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1

net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.all.forwarding=1

net.ipv4.ip_forward=1
EOF

sysctl -p /etc/sysctl.conf

cat >/etc/security/limits.d/all.conf <<EOF
*    - nofile 65536
root - nofile 65536
EOF

ulimit -n 65536

ifconfig eth0 mtu 1500

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o tun9 -j MASQUERADE

i=9
let j="10 + $i" ; let k="3${i}443" ; l="tun$i"
vdir="/opt/pki" ; verb="--verb 1" ; buff="16777216" ; mode="--tcp-queue-limit 256" #; mode=" ${mode} --bulk-mode "
keyx="ECDHE-ECDSA" ; ciph="CHACHA20-POLY1305" ; hash="SHA256" ; stls=$(echo "${ciph}" | tr '-' '_')
openvpn --proto tcp4 --local 0.0.0.0 --port ${k} --dev ${l} --persist-tun --tun-mtu 1750 --txqueuelen 9750                     \
  --mode server --server 10.${j}.${j}.0 255.255.255.0 --topology subnet --keepalive 10 30 --mssfix 0 ${mode}                   \
  --tls-ciphersuites TLS_${stls}_${hash} --tls-cipher TLS-${keyx}-WITH-${ciph}-${hash} --cipher ${ciph} --data-ciphers ${ciph} \
  --ca ${vdir}/sig.pem --cert ${vdir}/srv.pem --key ${vdir}/srv.key --duplicate-cn                                             \
  --dh none --auth-user-pass-verify ${vdir}/auth.sh via-env --script-security 3 --max-clients 28                               \
  --sndbuf $buff --rcvbuf $buff --push "sndbuf $buff" --push "rcvbuf $buff"                                                    \
  --log /var/log/ovpn${i}.log --status /var/log/stat${i}.log ${verb} --daemon

while true ; do sleep 10 ; done
