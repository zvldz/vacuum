#!/bin/sh

mkdir -p /var/log/upstart

while :; do
    sleep 5
    if [ `cut -d. -f1 /proc/uptime` -lt 300 ]; then
        echo -n "Waiting for 20 sec after boot..."
        sleep 20
        echo " done."
    fi
    echo '|/bin/false' > /proc/sys/kernel/core_pattern
    if [ -f "/root/bin/busybox" ]; then
        /root/bin/busybox ionice -c3 nice -n 19 /usr/local/bin/valetudo >> /var/log/upstart/valetudo.log 2>&1
    else
        nice -n 19 /usr/local/bin/valetudo >> /var/log/upstart/valetudo.log 2>&1
    fi
done
