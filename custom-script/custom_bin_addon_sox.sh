#!/usr/bin/env bash
# Addon contains program sox (SoX console audio player)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_bin_addon_sox")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_bin_addon_sox")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_bin_addon_sox")
LIST_CUSTOM_FUNCTION+=("custom_function_bin_addon_sox")
ENABLE_ADDON_SOX=${ENABLE_ADDON_SOX:-"0"}

function custom_print_usage_bin_addon_sox() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-addon-sox]
EOF
}

function custom_print_help_bin_addon_sox() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-addon-sox         Extract sox.tgz to firmware (SoX console audio player)
EOF
}

function custom_parse_args_bin_addon_sox() {
    case ${PARAM} in
        *-enable-addon-sox)
            ENABLE_ADDON_SOX=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_bin_addon_sox() {
    if [ $ENABLE_ADDON_SOX -eq 1 ]; then
        if [ -r "${FILES_PATH}/sox.tgz" ]; then
            echo "+ Unpacking addon-sox"
            tar -C "$IMG_DIR" -xzf "${FILES_PATH}/sox.tgz"
        else
            echo "- ${FILES_PATH}/sox.tgz not found/readable"
        fi
    fi
}
