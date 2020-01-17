#!/bin/sh

mkdir -p /var/log/upstart

echo '|/bin/false' > /proc/sys/kernel/core_pattern
/root/bin/busybox ionice -c3 nice -n 19 /usr/local/bin/valetudo > /var/log/upstart/valetudo.log
