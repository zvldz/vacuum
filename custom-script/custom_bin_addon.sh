#!/bin/bash
# Addon contains programs wget, bbe, nano, snmpd, htop

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_bin_addon")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_bin_addon")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_bin_addon")
LIST_CUSTUM_FUNCTION+=("custom_function_bin_addon")

function custom_print_usage_bin_addon()
{
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-addon]
EOF
}

function custom_print_help_bin_addon()
{
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-addon             Extract addon.tgz to firmware
EOF
}

function custom_parse_args_bin_addon()
{
    case ${PARAM} in
        *-enable-addon)
            ENABLE_ADDON=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_bin_addon()
{
    ENABLE_ADDON=${ENABLE_ADDON:-"0"}

    if [ $ENABLE_ADDON -eq 1 ]; then
        ADDON_PATH=$(dirname $(readlink_f ${BASH_SOURCE[0]}))
        if [ -r "$ADDON_PATH/addon.tgz" ]; then
            echo "+ Unpacking addon"
            tar -C $IMG_DIR -xzf $ADDON_PATH/addon.tgz
        else
            echo "- $ADDON_PATH/addon.tgz not found/readable"
        fi
    fi
}
