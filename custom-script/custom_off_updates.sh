#!/bin/bash
# Disable xiaomi servers using hosts file for firmware updates

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_off_updates")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_off_updates")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_off_updates")
LIST_CUSTOM_FUNCTION+=("custom_function_off_updates")

function custom_print_usage_off_updates() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--disable-firmware-updates]
EOF
}

function custom_print_help_off_updates() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --disable-firmware-updates Disable xiaomi servers using hosts file for firmware updates
EOF
}

function custom_parse_args_off_updates() {
    case ${PARAM} in
        *-disable-firmware-updates)
            DISABLE_XIAOMI=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_off_updates() {
    DISABLE_XIAOMI=${DISABLE_XIAOMI:-"0"}

    if [ $DISABLE_XIAOMI -eq 1 ]; then
        #echo "+ Reconfiguring network traffic to xiaomi"
        echo "+ Disable xiaomi servers using hosts file for firmware updates"
        # comment out this section if you do not want do disable the xiaomi cloud
        # or redirect it
        #echo "0.0.0.0       awsbj0-files.fds.api.xiaomi.com" >> $IMG_DIR/etc/hosts
        #echo "0.0.0.0       awsbj0.fds.api.xiaomi.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.awsbj0.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.awsde0.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.cnbj2.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.awssgp0.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.awsusor0.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.cnbj1.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.cnbj0.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.ksyru0-eco.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        echo "0.0.0.0         cdn.awsind0-eco.fds.api.mi-img.com" >> $IMG_DIR/etc/hosts
        #echo "0.0.0.0       ott.io.mi.com" >> ./etc/hosts
        #echo "0.0.0.0       ot.io.mi.com" >> ./etc/hosts
    fi
}
