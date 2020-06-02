#!/usr/bin/env bash
# Archive contains Dropbear v2019.78 with Ed25519 support

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_09_custom_dropbear")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_09_custom_dropbear")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_09_custom_dropbear")
LIST_CUSTOM_FUNCTION+=("custom_function_09_custom_dropbear")
ENABLE_CUSTOM_DROPBEAR=${ENABLE_CUSTOM_DROPBEAR:-"0"}

function custom_print_usage_01_custom_dropbear() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--custom-dropbear]
EOF
}

function custom_print_help_09_custom_dropbear() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --custom-dropbear          Extract dropbear_v2019.78.tgz to firmware (Dropbear v2019.78 with Ed25519 support)
EOF
}

function custom_parse_args_09_custom_dropbear() {
    case ${PARAM} in
        *-custom-dropbear)
            ENABLE_CUSTOM_DROPBEAR=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_09_custom_dropbear() {
    if [ $ENABLE_CUSTOM_DROPBEAR -eq 1 ]; then
        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            if [ -r "${FILES_PATH}/dropbear_v2019.78.tgz" ]; then
                echo "+ Unpacking dropbear_v2019.78"
                tar -C "$IMG_DIR" -xzf "${FILES_PATH}/dropbear_v2019.78.tgz"
                sed -i 's/dropbear -F.*/dropbear -FR/' "${IMG_DIR}/etc/inittab"
            else
                echo "- ${FILES_PATH}/dropbear_v2019.78.tgz not found/readable"
            fi
        fi
    fi
}
