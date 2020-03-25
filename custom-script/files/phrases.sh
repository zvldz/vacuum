#!/bin/bash

LANG=C LC_ALL=C
DIR='/mnt/data/random_phrases/phrases'

if [ `ls $DIR | wc -l` -eq 0 ]; then
    echo "sound directory is empty"
    exit
fi

if [ -f "/root/bin/busybox" ]; then
    SHUF="/root/bin/busybox shuf"
else
    SHUF=`which shuf`
fi

if [ -z "$SHUF" ]; then
    echo "'shuf' not found"
    exit 2
fi

HANDSHAKE='21310020ffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
ID=1
ATTEMPTS=50
TOKEN=$(head -c 16 /mnt/data/miio/device.token | xxd -p -c 1000000)
KEY=$(echo -n $TOKEN | xxd -r -p | md5sum | awk '{print $1}')
IV=$(echo -n $KEY | xxd -r -p | cat - <(echo -n $TOKEN | xxd -r -p) | md5sum | awk '{print $1}')
exec 3<>/dev/udp/127.0.0.1/54321
while [[ (-z "$STATUS" || -z "$VOLUME") && "$ATTEMPTS" -ne 0 ]]; do
    echo -n $HANDSHAKE | xxd -r -p >&3
    SHEADER=$(timeout 0.1 dd bs=16 count=1 <&3 2> /dev/null | xxd -p -c 1000000)
    if [ -z "$STATUS" ]; then
        MESSAGE=$(echo -n '{"method":"get_status","id":'$ID'}' | openssl aes-128-cbc -e -K $KEY -iv $IV | xxd -p -c 1000000)
        LENGTH=$(printf '%04x' $((32+${#MESSAGE}/2)))
        HEADER=$(echo -n ${SHEADER:0:4}$LENGTH${SHEADER:8})
        CHECKSUM=$(echo -n $HEADER$TOKEN$MESSAGE | xxd -r -p |  md5sum | awk '{print $1}')
        HEADER=$(echo -n ${HEADER:0:32}$CHECKSUM)
        PACKET=$HEADER$MESSAGE
        echo -n $PACKET  | xxd -r -p >&3
        STATUS=$(timeout 0.1 dd bs=999 count=1 <&3 2> /dev/null | xxd -p -c 1000000)
    fi
    if [ -z "$VOLUME" ]; then
        ID=$((ID+1))
        MESSAGE=$(echo -n '{"method":"get_sound_volume","id":'$ID'}' | openssl aes-128-cbc -e -K $KEY -iv $IV | xxd -p -c 1000000)
        LENGTH=$(printf '%04x' $((32+${#MESSAGE}/2)))
        HEADER=$(echo -n ${SHEADER:0:4}$LENGTH${SHEADER:8})
        CHECKSUM=$(echo -n $HEADER$TOKEN$MESSAGE | xxd -r -p |  md5sum | awk '{print $1}')
        HEADER=$(echo -n ${HEADER:0:32}$CHECKSUM)
        PACKET=$HEADER$MESSAGE
        echo -n $PACKET  | xxd -r -p >&3
        VOLUME=$(timeout 0.1 dd bs=999 count=1 <&3 2> /dev/null | xxd -p -c 1000000)
    fi
    ID=$((ID+10))
    ATTEMPTS=$((ATTEMPTS-1))
    echo -n '>'
done
echo ''
if [ -n "$STATUS" ]; then
    DECRYPTED=$(echo -n ${STATUS:64} | xxd -r -p | openssl aes-128-cbc -d -K $KEY -iv $IV)
    STATE=$(echo -n $DECRYPTED | sed 's/.*"state"\s*:\s*\([0-9]\+\).*/\1/')
    DND=$(echo -n $DECRYPTED | sed 's/.*"dnd_enabled"\s*:\s*\([0-9]\+\).*/\1/')
    if [[ "$DND" -eq 0 && ("$STATE" -eq 5 || "$STATE" -eq 11 || "$STATE" -eq 17 || "$STATE" -eq 18) ]]; then
        if [ -z "$VOLUME" ]; then
            VOLUME='0.5'
        else
            VOLUME=$(echo -n ${VOLUME:64} | xxd -r -p | openssl aes-128-cbc -d -K $KEY -iv $IV | sed 's/.*"result"\s*:\s*\[\s*\([0-9]\+\).*/\1/')
            VOLUME=$(printf '%03d'  $(((VOLUME - 30) * (100 - 10) / (90 - 30) + 10)) | sed 's/..$/.&/')
        fi
        FILE=$(ls $DIR | $SHUF -n 1)
        echo 'Play phrase' $FILE
        sox -v $VOLUME $DIR/$FILE -d > /dev/null 2>&1
    fi
fi
exec 3>&-
