#!/bin/sh

if [ ! -r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh --ntpserver=pool.ntp.org --replace-adbd --rrlogd-patcher=./patcher.py -valetudo-path=../Valetudo --2eu -f $1
