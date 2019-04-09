#!/bin/bash
# Turn off Chinese New Year
LIST_CUSTUM_FUNCTION+=("custom_function_off_cn_ny")

function custom_function_off_cn_ny()
{
    SILENT_PATH=$(dirname $(readlink_f ${BASH_SOURCE[0]}))
    if [ -r "$SILENT_PATH/silent.wav" ]; then
        echo "+ Turn off Chinese New Year"
        install -m 0644 $SILENT_PATH/silent.wav $IMG_DIR/opt/rockrobo/resources/sounds/start_greeting.wav
    else
        echo "- $SILENT_PATH/silent.wav not found/readable"
    fi
}
