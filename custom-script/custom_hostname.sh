#!/usr/bin/env bash
# Set a custom hostname

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_hostname")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_hostname")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_hostname")
LIST_CUSTOM_FUNCTION+=("custom_function_hostname")

function custom_print_usage_hostname() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--hostname=roborock]
EOF
}

function custom_print_help_hostname() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --hostname=HOSTNAME        Sets a custom hostname
EOF
}

function custom_parse_args_hostname() {
    case ${PARAM} in
        *-hostname)
            CUSTOM_HOSTNAME="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_hostname() {
    if [ -n "$CUSTOM_HOSTNAME" ]; then
        echo "+ Set hostname '${CUSTOM_HOSTNAME}'"
        echo ${CUSTOM_HOSTNAME} > "${IMG_DIR}/etc/hostname"
    fi
}

