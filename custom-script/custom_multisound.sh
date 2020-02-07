#!/bin/bash
# Make robot use different sounds at the same event

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_multisound")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_multisound")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_multisound")
LIST_CUSTOM_FUNCTION+=("custom_function_multisound")
ENABLE_MULTISOUND=${ENABLE_MULTISOUND:-"0"}

function custom_print_usage_multisound() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-multisound]
EOF
}

function custom_print_help_multisound() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-multisound             Make robot use different sounds at the same event
EOF
}

function custom_parse_args_multisound() {
    case ${PARAM} in
        *-enable-multisound)
            ENABLE_MULTISOUND=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_multisound() {
    if [ $ENABLE_MULTISOUND -eq 1 ]; then
        MULTISOUND_PATH=$(dirname $(readlink_f "${BASH_SOURCE[0]}"))
        if [ -r "$MULTISOUND_PATH/multisound.tgz" ]; then
            echo "+ Unpacking multisound files"
            tar -C "$IMG_DIR" -xzf "${MULTISOUND_PATH}/multisound.tgz"
            sed -E -i '/exit 0$/iif [ -d \/mnt\/data\/rockrobo\/sounds -a -d \/mnt\/data\/rockrobo\/sounds_multi ]; then \/usr\/local\/bin\/bbfs -o nonempty,allow_root \/mnt\/data\/rockrobo\/sounds_multi \/mnt\/data\/rockrobo\/sounds; fi' "${IMG_DIR}/etc/rc.local"
        else
            echo "- $MULTISOUND_PATH/multisound.tgz not found/readable"
        fi
    fi
}
