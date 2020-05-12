#!/usr/bin/env bash
# Access your network in unprovisioned mode (currently only wpa2psk is supported)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_unprovisioned")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_unprovisioned")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_unprovisioned")
LIST_CUSTOM_FUNCTION+=("custom_function_unprovisioned")
UNPROVISIONED=${UNPROVISIONED:-"0"}

function custom_print_usage_unprovisioned() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--unprovisioned|--ssid YOUR_SSID|--psk YOUR_WIRELESS_PASSWORD]
EOF
}

function custom_print_help_unprovisioned() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --unprovisioned            Access your network in unprovisioned mode (currently only wpa2psk is supported)
                             --unprovisioned wpa2psk
                             --ssid YOUR_SSID
                             --psk YOUR_WIRELESS_PASSWORD
EOF
}

function custom_parse_args_unprovisioned() {
    case ${PARAM} in
        *-unprovisioned)
            UNPROVISIONED=1
            WIFIMODE="$ARG"
            CUSTOM_SHIFT=1
            ;;
        *-ssid)
            SSID="$ARG"
            CUSTOM_SHIFT=1
            ;;
        *-psk)
            PSK="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_unprovisioned() {
    if [ $UNPROVISIONED -eq 1 ]; then
        echo "+ Implementing unprovisioned mode"

        if [ -z "$WIFIMODE" ]; then
            echo "-- You need to specify a Wifi Mode: currently only wpa2psk is supported"
            cleanup_and_exit 1
        fi

        echo "++ Wifimode: $WIFIMODE"

        if [ "$WIFIMODE" = "wpa2psk" ]; then
            if [ -z "$SSID" ]; then
            echo "-- No SSID given, please use --ssid YOURSSID"
            cleanup_and_exit 1
            fi

            if [ -z "$PSK" ]; then
                echo "-- No PSK (Wireless Password) given, please use --psk YOURPASSWORD"
                cleanup_and_exit 1
            fi

            mkdir "${IMG_DIR}/opt/unprovisioned"
            install -m 0755 "${FILES_PATH}/unprovisioned/start_wifi.sh" "${IMG_DIR}/opt/unprovisioned"

            sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
            cat "${FILES_PATH}/unprovisioned/rc.local" >> "${IMG_DIR}/etc/rc.local"
            echo "exit 0" >> "${IMG_DIR}/etc/rc.local"

            install -m 0644 "${FILES_PATH}/unprovisioned/wpa_supplicant.conf.wpa2psk" "${IMG_DIR}/opt/unprovisioned/wpa_supplicant.conf"

            sed -i 's/#SSID#/'"$SSID"'/g' "${IMG_DIR}/opt/unprovisioned/wpa_supplicant.conf"
            sed -i 's/#PSK#/'"$PSK"'/g'   "${IMG_DIR}/opt/unprovisioned/wpa_supplicant.conf"
        fi
    fi
}
