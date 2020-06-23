#!/usr/bin/env bash

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_protect_ap")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_protect_ap")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_protect_ap")
LIST_CUSTOM_FUNCTION+=("custom_function_01_protect_ap")
AP_PSK=${AP_PSK:-""}

function custom_print_usage_01_protect_ap() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--protect-ap=PASSWORD]
EOF
}

function custom_print_help_01_protect_ap() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --protect-ap=PASSWORD      Protect the AP with a password
EOF
}

function custom_parse_args_01_protect_ap() {
    case ${PARAM} in
        *-protect-ap)
            AP_PSK="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_protect_ap() {
    if [ -n "$AP_PSK" ]; then
        if [ ! -f "${IMG_DIR}/etc/inittab" ]; then
            echo "+ Setting password for AP"
            sed -i "s/create_ap -c \$channel -n wlan0 -g 192.168.8.1 \$ssid_ap --daemon/create_ap -c \$channel -n wlan0 -g 192.168.8.1 \$ssid_ap $AP_PSK --daemon/g" \
                "${IMG_DIR}/opt/rockrobo/wlan/wifi_start.sh"
        else
            echo "+ Setting password for AP(fw 2008+) (Not tested !!!)"
            sed -i -E "s/(.*hw_mode=b.*)/\1\n        echo \"wpa_passphrase=$AP_PSK\" >> \${HOSTAPD_CONF}/" "${IMG_DIR}/opt/rockrobo/wlan/wifi_start.sh"
        fi
    fi
}
