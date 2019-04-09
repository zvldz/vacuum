#!/bin/bash

LIST_CUSTUM_FUNCTION+=("custom_function_bin_addon")

function custom_function_bin_addon()
{
    ADDON_PATH=$(dirname $(readlink_f ${BASH_SOURCE[0]}))
    if [ -r "$ADDON_PATH/addon.tgz" ]; then
        echo "+ Unpacking addon"
        tar -C $IMG_DIR -xzf $ADDON_PATH/addon.tgz
    else
        echo "- $ADDON_PATH/addon.tgz not found/readable"
    fi
}
