#!/bin/sh

if [ ! -r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh --ntpserver=pool.ntp.org --dnsserver="8.8.8.8, 114.114.114.114" --disable-logs --replace-adbd --rrlogd-patcher=./patcher.py -valetudo-path=../Valetudo --2eu -f $1
