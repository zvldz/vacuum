#!/bin/bash
# Timezone to be used in vacuum

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_timezone")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_timezone")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_timezone")
LIST_CUSTOM_FUNCTION+=("custom_function_timezone")

function custom_print_usage_timezone() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--timezone=Europe/Berlin]
EOF
}

function custom_print_help_timezone() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  -t, --timezone             Timezone to be used in vacuum
EOF
}

function custom_parse_args_timezone() {
    case ${PARAM} in
        *-timezone|-t)
            TIMEZONE="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_timezone() {
    TIMEZONE=${TIMEZONE:-"Europe/Berlin"}
    echo "+ Replacing timezone"
    echo "$TIMEZONE" > "${IMG_DIR}/etc/timezone"
}
