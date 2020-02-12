#!/bin/bash
# Install dummycloud

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_dummycloud")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_dummycloud")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_dummycloud")
LIST_CUSTOM_FUNCTION+=("custom_function_dummycloud")
ENABLE_DUMMYCLOUD=${ENABLE_DUMMYCLOUD:-"0"}

function custom_print_usage_dummycloud() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--dummycloud-path=PATH]
EOF
}

function custom_print_help_dummycloud() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --dummycloud-path=PATH     Provide the path to dummycloud
EOF
}

function custom_parse_args_dummycloud() {
    case ${PARAM} in
        *-dummycloud-path)
            DUMMYCLOUD_PATH="$ARG"
            if [ -r "${DUMMYCLOUD_PATH}/dummycloud" ]; then
                ENABLE_DUMMYCLOUD=1
            else
                echo "The dummycloud binary hasn't been found in $DUMMYCLOUD_PATH"
                echo "Please download it from https://github.com/dgiese/dustcloud"
                cleanup_and_exit 1
            fi
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_dummycloud() {
    if [ $ENABLE_VALETUDO -eq 1  ] && [ $ENABLE_DUMMYCLOUD -eq 1 ]; then
        echo "You can't install Valetudo and Dummycloud at the same time, "
        echo "because Valetudo has implemented Dummycloud fuctionality and map upload support now."
        cleanup_and_exit 1
    fi

    if [ $ENABLE_DUMMYCLOUD -eq 1 ]; then
        echo "Installing dummycloud"

        install -m 0755 "${DUMMYCLOUD_PATH}/dummycloud" "${IMG_DIR}/usr/local/bin/dummycloud"
        cat "${DUMMYCLOUD_PATH}/doc/dummycloud.conf" | tr -d '\15\32' > "${IMG_DIR}/etc/init/dummycloud.conf"
        cat "${DUMMYCLOUD_PATH}/doc/etc_hosts-snippet.txt" | tr -d '\15\32' >> "${IMG_DIR}/etc/hosts"
        sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
        cat "${DUMMYCLOUD_PATH}/doc/etc_rc.local-snippet.txt" | tr -d '\15\32' >> "${IMG_DIR}/etc/rc.local"
        echo >> "${IMG_DIR}/etc/rc.local"
        echo "exit 0" >> "${IMG_DIR}/etc/rc.local"

        # UPLOAD_METHOD   0:NO_UPLOAD    1:FTP    2:FDS
        sed -i -E 's/(UPLOAD_METHOD=)([0-9]+)/\10/' "${IMG_DIR}/opt/rockrobo/rrlog/rrlog.conf"
        sed -i -E 's/(UPLOAD_METHOD=)([0-9]+)/\10/' "${IMG_DIR}/opt/rockrobo/rrlog/rrlogmt.conf"

        # Let the script cleanup logs
        sed -i 's/nice.*//' "${IMG_DIR}/opt/rockrobo/rrlog/tar_extra_file.sh"

        # Disable collecting device info to /dev/shm/misc.log
        sed -i '/^\#!\/bin\/bash$/a exit 0' "${IMG_DIR}/opt/rockrobo/rrlog/misc.sh"

        # Disable logging of 'top'
        sed -i '/^\#!\/bin\/bash$/a exit 0' "${IMG_DIR}/opt/rockrobo/rrlog/toprotation.sh"
        sed -i '/^\#!\/bin\/bash$/a exit 0' "${IMG_DIR}/opt/rockrobo/rrlog/topstop.sh"
    fi
}
