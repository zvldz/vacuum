#!/bin/sh

if [ ! -r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh --unpack-and-mount -f $1
