#!/bin/sh

echo
date
echo $0

if [ ! -r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh     --run-custom-script=ALL \
                        --timezone=Europe/Berlin \
                        --ntpserver=pool.ntp.org \
                        --root-pass=cleaner \
                        --custom-user=cleaner \
                        --custom-user-pass=cleaner \
                        --enable-greeting \
                        --enable-addon \
                        --enable-binding \
                        --enable-turn-off-ny \
                        --disable-logs \
                        --enable-ramdisk \
                        --replace-adbd \
                        --enable-appproxy-patcher \
                        --valetudo-path=../Valetudo \
                        --replace-miio \
                        --enable-dns-catcher \
                        --enable-addon-sox \
                        --enable-random-phrases \
                        --enable-local-ota \
                        --resize-root-fs=522240 \
                        -f "$1"
