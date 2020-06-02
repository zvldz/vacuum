#!/usr/bin/env bash
# AppProxy patch to disable timezone checking (Anonymous author)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_appproxy_patcher")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_appproxy_patcher")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_appproxy_patcher")
LIST_CUSTOM_FUNCTION+=("custom_function_01_appproxy_patcher")
PATCH_APPPROXY=${PATCH_APPPROXY:-"0"}

function custom_print_usage_01_appproxy_patcher() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-appproxy-patcher]
EOF
}

function custom_print_help_01_appproxy_patcher() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-appproxy-patcher  AppProxy patch to disable timezone checking
EOF
}

function custom_parse_args_01_appproxy_patcher() {
    case ${PARAM} in
        *-enable-appproxy-patcher)
            PATCH_APPPROXY=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_appproxy_patcher() {
    if [ $PATCH_APPPROXY -eq 1 ]; then
        echo "+ Trying to patch AppProxy to disable timezone check"
        cp "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy" "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi"
        sed -i 's/\x0B\x28\x02\x90\xD8\xBF\x00\x24\x0C\xB9\x06\x2F\x14\xD8/\x3C\x28\x02\x90\xD8\xBF\x00\x24\x0C\xB9\x06\x2F\x14\xD8/g' "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy"
        MD5_ORG=$(md5sum "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi" | awk '{print $1}')
        MD5_PATCHED=$(md5sum "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy" | awk '{print $1}')

        if [ "$MD5_ORG" = "$MD5_PATCHED" ]; then
            echo "-- AppProxy is NOT patched."
        else
            echo "++ AppProxy is patched."
        fi
    fi

    rm -f "${IMG_DIR}/opt/rockrobo/cleaner/bin/AppProxy.xiaomi"
}
