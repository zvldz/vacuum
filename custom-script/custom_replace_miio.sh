#!/bin/bash
# Replaces miio to version 3.3.9

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_replace_miio")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_replace_miio")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_replace_miio")
LIST_CUSTOM_FUNCTION+=("custom_function_replace_miio")

function custom_print_usage_replace_miio() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--replace-miio]
EOF
}

function custom_print_help_replace_miio() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --replace-miio             Replaces miio to version 3.3.9
EOF
}

function custom_parse_args_replace_miio() {
    case ${PARAM} in
        *-replace-miio)
            PATCH_MIIO=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_replace_miio() {
    PATCH_MIIO=${PATCH_MIIO:-"0"}

    if [ $PATCH_MIIO -eq 1 ]; then
        MIIO_PATH=$(dirname $(readlink_f "${BASH_SOURCE[0]}"))
        if [ -r "$MIIO_PATH/miio_3_3_9.tgz" ]; then
            echo "+ Unpacking miio 3.3.9"
            tar -C "${IMG_DIR}" -xzf "${MIIO_PATH}/miio_3_3_9.tgz"
        else
            echo "- $MIIO_PATH/miio_3_3_9.tgz not found/readable"
        fi
    fi
}
