#!/bin/sh

mkdir -p /var/log/upstart

while :; do
    if [ -f "/root/bin/date" ] && [ -f "/root/bin/busybox" ]; then
        # give roborock software some time to initialize if started at boot or right after them
        wdp=`pidof WatchDoge`
        if [ `cut -d. -f1 /proc/uptime` -lt 300 ]; then
            echo -n "Waiting for 30 sec after boot..."
            sleep 30
            echo " done."
        elif [ -n "$wdp" -a $(/root/bin/date +%s --date="now - `/root/bin/busybox stat -c%X /proc/$wdp` seconds") -lt 60 ]; then
            echo -n "Waiting for 15 sec after watchdoge launch..."
            sleep 15
            echo " done."
        fi
        # check data partition to be mounted before doing anything
        while ! /root/bin/busybox mountpoint -q /mnt/data; do
            echo "Data mountpoint isn't ready, can't run yet. Retrying in 5 sec..."
            sleep 5
        done
        # disable core dumps on this system, we're in production
        echo '|/bin/false' > /proc/sys/kernel/core_pattern
        # finally run valetudo
        /root/bin/busybox ionice -c3 /usr/local/bin/valetudo > /var/log/upstart/valetudo.log
    else
        sleep 90
        /usr/local/bin/valetudo > /var/log/upstart/valetudo.log
    fi

    sleep 5
done
