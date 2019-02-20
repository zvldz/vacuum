#!/bin/sh

if [ !-r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh --rrlogd-patcher=./patcher.py -valetudo-path=../Valetudo --2prc -f $1
