#!/usr/bin/env bash
# Set custom NTP servers

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_ntp")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_ntp")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_ntp")
LIST_CUSTOM_FUNCTION+=("custom_function_ntp")

function custom_print_usage_ntp() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--ntpserver=ADDRESS]
EOF
}

function custom_print_help_ntp() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --ntpserver=ADDRESS        Set your local NTP server
EOF
}

function custom_parse_args_ntp() {
    case ${PARAM} in
        *-ntpserver)
            NTPSERVER="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_ntp() {
    if [ -n "$NTPSERVER" ]; then
        echo "+ Replacing NTP servers"
        echo "$NTPSERVER" > "${IMG_DIR}/opt/rockrobo/watchdog/ntpserver.conf"
    fi
}
