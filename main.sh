#!/bin/bash
#ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -p 4321 root@127.0.0.1

ADDR="127.0.0.1"
PORT=" -p ${ADDR}:4321:22/tcp "

if [ "$2" == "" ] ; then echo "noop" ; fi
if [ "$1" != "" ] ; then ADDR="$1" ; fi

for p in 39443 ; do PORT=" ${PORT} -p ${ADDR}:${p}:${p}/tcp " ; done

rm -fr src
mkdir -p src
git clone https://github.com/stoops/openvpn-fork.git src
cd src
git checkout mtio
cd ..

mkdir -p pki
touch pki/{sig.pem,srv.pem,srv.key}
touch pki/auth.sh

chmod 700 *

date

if [ "$2" != "" ] ; then
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  docker image prune --all --force
fi

date
sleep 5

docker pull --platform=linux/arm64 arm64v8/debian:latest
docker build -t ovpn .
docker run --device /dev/net/tun --cap-add NET_ADMIN --privileged --restart always -d $PORT ovpn

date
