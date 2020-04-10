#!/usr/bin/env bash
# Patch rrlogd to disable log encryption (based on https://github.com/JohnRev/rrlogd-patcher)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_rrlogd_patcher")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_rrlogd_patcher")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_rrlogd_patcher")
LIST_CUSTOM_FUNCTION+=("custom_function_rrlogd_patcher")
PATCH_RRLOGD=${PATCH_RRLOGD:-"0"}

function custom_print_usage_rrlogd_patcher() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-rrlogd-patcher]
EOF
}

function custom_print_help_rrlogd_patcher() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-rrlogd-patcher    Patch rrlogd to disable log encryption (only use with dummycloud or dustcloud)
EOF
}

function custom_parse_args_rrlogd_patcher() {
    case ${PARAM} in
        *-enable-rrlogd-patcher)
            PATCH_RRLOGD=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_rrlogd_patcher() {
    if [ $PATCH_RRLOGD -eq 1 ]; then
        echo "+ Creating backup of rrlogd"
        cp "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd" "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd.xiaomi"

        echo "+ Trying to patch rrlogd"
        sed -i 's/\xF2\x04\x03\xFF\xF7\x4B\xFF/\xF2\x04\x03\xE3\x20\x4B\xFF/g' "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd"
        sed -i 's/\xF2\x04\x03\xFF\xF7\x45\xFF/\xF2\x04\x03\xE3\x20\x45\xFF/g' "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd"
        sed -i 's/\x33\x46\x4B\xA8\x10\x22/\x33\x46\x47\xA8\x10\x22/g' "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd"
        MD5_ORG=$(md5sum "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd.xiaomi" | awk '{print $1}')
        MD5_PATCHED=$(md5sum "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd" | awk '{print $1}')

        if [ "$MD5_ORG" = "$MD5_PATCHED" ]; then
            echo "- rrlogd is NOT patched."
            rm "${IMG_DIR}/opt/rockrobo/rrlog/rrlogd.xiaomi"
        else
            echo "+ rrlogd is patched."
        fi
    fi
}
