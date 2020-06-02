#!/usr/bin/env bash
# Enable local ota on 2008+ firmware
# Author: @JohnRev

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_enable_local_ota")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_enable_local_ota")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_enable_local_ota")
LIST_CUSTOM_FUNCTION+=("custom_function_01_enable_local_ota")
ENABLE_LOCAL_OTA=${ENABLE_LOCAL_OTA:-"0"}

function custom_print_usage_01_enable_local_ota() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-local-ota]
EOF
}

function custom_print_help_01_enable_local_ota() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-local-ota         Enable local ota on 2008+ firmware
EOF
}

function custom_parse_args_01_enable_local_ota() {
    case ${PARAM} in
        *-enable-local-ota)
            ENABLE_LOCAL_OTA=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_enable_local_ota() {
    if [ $ENABLE_LOCAL_OTA -eq 1 ]; then
        echo "+ Enable local ota"
        echo "++ Trying to patch AppProxy"
        cp "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy" "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi"
        sed -i 's/\x7F\xF4\x29\xAF\x13\x79\x03\xF0\xDF\x03\x53\x2B\x7F\xF4\xCD\xAC\x21\xE7\x38\x46\xF0\xF7\xE2\xEB/\x7F\xF4\x29\xAF\xD3\x78\x03\xF0\xDF\x03\x50\x2B\x7F\xF4\xCD\xAC\x21\xE7\x38\x46\xF0\xF7\xE2\xEB/g' "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy"
        MD5_ORG=$(md5sum "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi" | awk '{print $1}')
        MD5_PATCHED=$(md5sum "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy" | awk '{print $1}')

        if [ "$MD5_ORG" = "$MD5_PATCHED" ]; then
            echo "-- AppProxy is NOT patched"
            echo "!! Probably this firmware is not 2008+"
        else
            echo "++ AppProxy is patched"
            echo "++ Trying to patch SysUpdate"
            cp "${IMG_DIR}/opt/rockrobo/cleaner/bin/SysUpdate" "${IMG_DIR}/opt/rockrobo/cleaner/bin/SysUpdate.xiaomi"
            sed -i 's/\x0B\x79\x03\xF0\xDF\x03\x53\x2B\x3E\xD0\x4C/\xCB\x78\x03\xF0\xDF\x03\x50\x2B\x3E\xD0\x4C/g' "${IMG_DIR}/opt/rockrobo/cleaner/bin/SysUpdate"
            MD5_ORG=$(md5sum "${IMG_DIR}/opt/rockrobo/cleaner/bin/SysUpdate.xiaomi" | awk '{print $1}')
            MD5_PATCHED=$(md5sum "${IMG_DIR}/opt/rockrobo/cleaner/bin/SysUpdate" | awk '{print $1}')

            if [ "$MD5_ORG" = "$MD5_PATCHED" ]; then
                echo "-- SysUpdate is NOT patched"
                echo "!! Restore original AppProxy"
                echo "!! Probably this firmware is not 2008+"
                cp "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi" "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy"
            else
            echo "++ SysUpdate is patched"
            fi
        fi
    fi

    rm -f "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi"
    rm -f "${IMG_DIR}/opt/rockrobo/cleaner/bin/SysUpdate.xiaomi"
}
