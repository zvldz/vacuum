#!/bin/bash
# Region conversion. Edit users.

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_vacuum")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_vacuum")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_vacuum")
LIST_CUSTUM_FUNCTION+=("custom_function_vacuum")

function custom_print_usage_vacuum()
{
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--root-password=PASSWORD|--custom-user=USER|--custom-user-pass=PASSWORD|
--convert2prc|--convert2eu]
EOF
}

function custom_print_help_vacuum()
{
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --root-pass=PASSWORD         Set password for root and custom user
  --custom-user=USER           Add custom user
  --custom-user-pass=PASSWORD  Set password for custom user
  --convert2prc                Convert to Mainland China region
  --convert2eu                 Convert to EU region
EOF
}

function custom_parse_args_vacuum()
{
    case ${PARAM} in
        *-convert2prc)
            CONVERT_2_PRC=1
            ;;
        *-convert2eu)
            CONVERT_2_EU=1
            ;;
        *-root-pass)
            ROOT_PASSWORD="$ARG"
            CUSTOM_SHIFT=1
            ;;
        *-custom-user)
            CUSTOM_USER="$ARG"
            CUSTOM_SHIFT=1
            ;;
        *-custom-user-pass)
            CUSTOM_USER_PASSWORD="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_vacuum()
{
    VERSION=`date "+%Y%m%d"`
    ROOT_PASSWORD=${ROOT_PASSWORD:-""}
    CUSTOM_USER=${CUSTOM_USER:-""}
    CUSTOM_USER_PASSWORD=${CUSTOM_USER_PASSWORD:-""}
    CONVERT_2_PRC=${CONVERT_2_PRC:-"0"}
    CONVERT_2_EU=${CONVERT_2_EU:-"0"}

    if [ $CONVERT_2_PRC -eq 1 -a $CONVERT_2_EU  -eq 1 ]; then
        echo "! Only one region is possible"
        exit 1
    fi

    echo "+ Prepare startup scripts"

    cat << EOF > $IMG_DIR/root/run_once.sh
#!/bin/sh

date >> /root/vacuum.txt

echo "Run custom scripts" >> /root/vacuum.txt

if [ -d /root/run.d ]; then
    for FILE in /root/run.d/*.sh; do
        if [ -r \$FILE ]; then
            echo "RUN - \$FILE" >> /root/vacuum.txt
            . \$FILE
        fi
    done
    unset FILE
fi

echo "Delete scripts after execution" >> /root/vacuum.txt
sed -i -E 's/.*run_once.*//' /etc/rc.local
rm -rf /root/run_once.sh /root/run.d
echo "END" >> /root/vacuum.txt
EOF

    if [ -n "$ROOT_PASSWORD" ]; then
        echo "+ Added script to change password for root"
        mkdir -p $IMG_DIR/root/run.d
        cat << EOF > $IMG_DIR/root/run.d/set_root_pass.sh
#!/bin/sh
echo "  - Set a password for root" >> /root/vacuum.txt
echo "root:$ROOT_PASSWORD" | chpasswd
EOF
    fi

    if [ -n "$CUSTOM_USER" -a -n "$CUSTOM_USER_PASSWORD" ]; then
        echo "+ Added script to create custom user"
        mkdir -p $IMG_DIR/root/run.d
        cat << EOF > $IMG_DIR/root/run.d/create_custom_user.sh
#!/bin/sh
echo "  - Create custom user" >> /root/vacuum.txt
echo "$CUSTOM_USER:$CUSTOM_USER_PASSWORD::::/home/$CUSTOM_USER:/bin/bash" | newusers
usermod -G sudo $CUSTOM_USER
EOF
    fi

    if [ $CONVERT_2_PRC -eq 1 ]; then
        echo "+ Added script for change region to Mainland China"
        mkdir -p $IMG_DIR/root/run.d
        cat << EOF > $IMG_DIR/root/run.d/convert2prc.sh
#!/bin/sh

if [ -f /mnt/default/roborock.conf ]; then
    cat /mnt/default/roborock.conf | grep 'location=prc' > /dev/null 2>&1
    if [ "\$?" -ne 0 ]; then
        mount -o remount,rw /mnt/default
        if [ -w /mnt/default/roborock.conf ]; then
            echo "  - Change region to Mainland China" >> /root/vacuum.txt
            cp /mnt/default/roborock.conf /mnt/default/roborock.conf.\`date "+%Y-%m-%d_%H-%M"\`
            sed -i 's/location.*/location=prc/' /mnt/default/roborock.conf
        fi
        mount -o remount,ro /mnt/default
    fi
fi
EOF
    elif [ $CONVERT_2_EU -eq 1 ]; then
        echo "+ Added script for change region to EU"
        mkdir -p $IMG_DIR/root/run.d
        cat << EOF > $IMG_DIR/root/run.d/convert2eu.sh
#!/bin/sh

if [ -f /mnt/default/roborock.conf ]; then
    cat /mnt/default/roborock.conf | grep 'location=de' > /dev/null 2>&1
    if [ "\$?" -ne 0 ]; then
        mount -o remount,rw /mnt/default
        if [ -w /mnt/default/roborock.conf ]; then
            echo "  - Change region to EU" >> /root/vacuum.txt
            cp /mnt/default/roborock.conf /mnt/default/roborock.conf.\`date "+%Y-%m-%d_%H-%M"\`
            sed -i 's/location.*/location=de/' /mnt/default/roborock.conf
        fi
        mount -o remount,ro /mnt/default
    fi
fi
EOF
    fi

    chmod +x $IMG_DIR/root/run_once.sh $IMG_DIR/root/run.d/*
    sed -i -E 's/^exit 0/\/root\/run_once.sh\nexit 0/' $IMG_DIR/etc/rc.local

    if [ $CONVERT_2_PRC -eq 1 ]; then
        FIRMWARE_BASENAME="${FIRMWARE_FILENAME}_vacuum_2prc_${VERSION}.pkg"
    elif [ $CONVERT_2_EU -eq 1 ]; then
        FIRMWARE_BASENAME="${FIRMWARE_FILENAME}_vacuum_2eu_${VERSION}.pkg"
    else
        FIRMWARE_BASENAME="${FIRMWARE_FILENAME}_vacuum_${VERSION}.pkg"
    fi

    FIRMWARE_FILENAME="${FIRMWARE_BASENAME%.*}"
}
