#!/usr/bin/env bash
# Add buildnumber and firmware version to history file

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_history")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_history")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_history")
LIST_CUSTOM_FUNCTION+=("custom_function_history")
ENABLE_HISTORY=${ENABLE_HISTORY:-"0"}

function custom_print_usage_history() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-history]
EOF
}

function custom_print_help_history() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-history           Add buildnumber and firmware version to history file
EOF
}

function custom_parse_args_history() {
    case ${PARAM} in
        *-enable-history)
            ENABLE_HISTORY=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_history() {
    if [ $ENABLE_HISTORY -eq 1 ]; then
        echo "+ Add buildnumber and firmware version to history file"
        BUILD_NUMBER=$(cat "${IMG_DIR}/opt/rockrobo/buildnumber" | tr -d '\n')
        if [ -f "${IMG_DIR}/opt/rockrobo/rr-release" ]; then
            FW_VERSION=$(cat "${IMG_DIR}/opt/rockrobo/rr-release" | grep -E '^(ROBOROCK_VERSION|ROCKROBO_VERSION)'| cut -f2 -d=)
        elif [ -f "${IMG_DIR}/etc/os-release" ]; then
            FW_VERSION=$(cat "${IMG_DIR}/etc/os-release" | grep -E '^(ROBOROCK_VERSION|ROCKROBO_VERSION)'| cut -f2 -d=)
        else
            FW_VERSION="-"
        fi
        echo "$FIRMWARE_BASENAME $BUILD_NUMBER $FW_VERSION" >> "${BASEDIR}/history.txt"
        sort -u "${BASEDIR}/history.txt" > "${BASEDIR}/history.txt.tmp"
        mv "${BASEDIR}/history.txt.tmp" "${BASEDIR}/history.txt"
    fi
}
