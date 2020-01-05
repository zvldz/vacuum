#!/bin/bash
# Install Valetudo (https://github.com/Hypfer/Valetudo)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_valetudo")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_valetudo")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_valetudo")
LIST_CUSTOM_FUNCTION+=("custom_function_valetudo")
ENABLE_VALETUDO=${ENABLE_VALETUDO:-"0"}

function custom_print_usage_valetudo() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--valetudo-path=PATH]
EOF
}

function custom_print_help_valetudo() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --valetudo-path=PATH       The path to Valetudo(https://github.com/Hypfer/Valetudo) to include it into the image
EOF
}

function custom_parse_args_valetudo() {
    case ${PARAM} in
        *-valetudo-path)
            VALETUDO_PATH="$ARG"
            if [ -r "$VALETUDO_PATH/valetudo" ]; then
                ENABLE_VALETUDO=1
            else
                echo "The Valetudo binary hasn't been found in $VALETUDO_PATH"
                echo "Please download it from https://github.com/Hypfer/Valetudo"
                echo "(example: git clone https://github.com/Hypfer/Valetudo ../Valetudo && wget https://github.com/Hypfer/Valetudo/releases/download/0.4.0/valetudo -O ../Valetudo/valetudo)"
                echo
                cleanup_and_exit 1
            fi
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_valetudo() {
    if [ $ENABLE_VALETUDO -eq 1 ] && [ $ENABLE_DUMMYCLOUD -eq 1 ]; then
        echo "You can't install Valetudo and Dummycloud at the same time, "
        echo "because Valetudo has implemented Dummycloud fuctionality and map upload support now."
        cleanup_and_exit 1
    fi

    if [ $ENABLE_VALETUDO_RE -eq 1 ] && [ $ENABLE_VALETUDO -eq 1 ]; then
        echo "You can't install Valetudo RE and Valetudo at the same time, "
        cleanup_and_exit 1
    fi

    if [ $ENABLE_VALETUDO -eq 1 ]; then
        echo "+ Installing Valetudo"

        install -m 0755 "${VALETUDO_PATH}/valetudo" "${IMG_DIR}/usr/local/bin/valetudo"
        install -m 0644 "${VALETUDO_PATH}/deployment/valetudo.conf" "${IMG_DIR}/etc/init/valetudo.conf"

        cat "${VALETUDO_PATH}/deployment/etc/hosts" >> "${IMG_DIR}/etc/hosts"

        sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
        cat "${VALETUDO_PATH}/deployment/etc/rc.local" >> "${IMG_DIR}/etc/rc.local"
        echo >> "${IMG_DIR}/etc/rc.local"
        echo "exit 0" >> "${IMG_DIR}/etc/rc.local"

        # UPLOAD_METHOD=2
        sed -i -E 's/(UPLOAD_METHOD=)([0-9]+)/\12/' "${IMG_DIR}/opt/rockrobo/rrlog/rrlog.conf"
        sed -i -E 's/(UPLOAD_METHOD=)([0-9]+)/\12/' "${IMG_DIR}/opt/rockrobo/rrlog/rrlogmt.conf"

        # Set LOG_LEVEL=3
        sed -i -E 's/(LOG_LEVEL=)([0-9]+)/\13/' "${IMG_DIR}/opt/rockrobo/rrlog/rrlog.conf"
        sed -i -E 's/(LOG_LEVEL=)([0-9]+)/\13/' "${IMG_DIR}/opt/rockrobo/rrlog/rrlogmt.conf"

        # Reduce logging of miio_client
        sed -i 's/-l 2/-l 0/' "${IMG_DIR}/opt/rockrobo/watchdog/ProcessList.conf"

        # Let the script cleanup logs
        sed -i 's/nice.*//' "${IMG_DIR}/opt/rockrobo/rrlog/tar_extra_file.sh"

        # Disable collecting device info to /dev/shm/misc.log
        sed -i '/^\#!\/bin\/bash$/a exit 0' "${IMG_DIR}/opt/rockrobo/rrlog/misc.sh"

        # Disable logging of 'top'
        sed -i '/^\#!\/bin\/bash$/a exit 0' "${IMG_DIR}/opt/rockrobo/rrlog/toprotation.sh"
        sed -i '/^\#!\/bin\/bash$/a exit 0' "${IMG_DIR}/opt/rockrobo/rrlog/topstop.sh"
    fi
}
