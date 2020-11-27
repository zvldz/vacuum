#!/usr/bin/env bash
# Send logs to remote syslog server

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_remote_syslog")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_remote_syslog")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_remote_syslog")
LIST_CUSTOM_FUNCTION+=("custom_function_01_remote_syslog")

function custom_print_usage_01_remote_syslog() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--remote-syslog=ADDRESS]
EOF
}

function custom_print_help_01_remote_syslog() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --remote-syslog=ADDRESS    Send logs to remote syslog server(ADDRESS = ADDRESS:PORT)
EOF
}

function custom_parse_args_01_remote_syslog() {
    case ${PARAM} in
        *-remote-syslog)
            SYSLOG_SERVER="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_remote_syslog() {
    if [ -n "$SYSLOG_SERVER" ]; then
        echo "+ Adding remote syslog server"
        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            sed -i "s/SYSLOGD_ARGS=-n/SYSLOGD_ARGS=\"-n -R $SYSLOG_SERVER -L -O \/var\/log\/messages\"/" "${IMG_DIR}/etc/init/S01logging"
        else
            echo "*.* @$SYSLOG_SERVER" >> "${IMG_DIR}/etc/rsyslog.conf"
        fi
    fi
}
