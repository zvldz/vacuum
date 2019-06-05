#!/bin/sh

if [ ! -r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh     --run-custom-script=ALL \
                        --disable-logs --replace-adbd \
                        --valetudo-path-wod=../Valetudo_0_2_3 \
                        --dnsserver="8.8.8.8, 114.114.114.114" \
                        --root-pass=cleaner \
                        --custom-user=cleaner \
                        --custom-user-pass=cleaner \
                        --enable-greeting \
                        --enable-addon \
                        --enable-binding \
                        --enable-turn-off-ny \
                        --convert2prc \
                        --enable-history \
                        -f $1
