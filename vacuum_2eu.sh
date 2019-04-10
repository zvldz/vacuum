#!/bin/sh

if [ ! -r "$1" ]; then
    echo "File not found!"
    exit 1
fi

./builder_vacuum.sh --run-custom-script=./custom-script/custom_vacuum.sh --run-custom-script=./custom-script/custom_greeting.sh --run-custom-script=./custom-script/custom_binding.sh --run-custom-script=./custom-script/custom_dns.sh --run-custom-script=./custom-script/custom_bin_addon.sh --run-custom-script=./custom-script/custom_off_cn_ny.sh --run-custom-script=./custom-script/custom_valetudo_wo_dummycloud.sh --ntpserver=pool.ntp.org --disable-logs --replace-adbd --rrlogd-patcher=./patcher.py --valetudo-path-wod=../Valetudo_0_2_3 --dnsserver="8.8.8.8, 114.114.114.114" --root-pass=cleaner --custom-user=cleaner --custom-user-pass=cleaner --convert2eu -f $1
