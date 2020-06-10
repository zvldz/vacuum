#!/usr/bin/env bash
# Install Valetudo (https://github.com/Hypfer/Valetudo)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_05_valetudo")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_05_valetudo")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_05_valetudo")
LIST_CUSTOM_FUNCTION+=("custom_function_05_valetudo")
ENABLE_VALETUDO=${ENABLE_VALETUDO:-"0"}

function custom_print_usage_05_valetudo() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--valetudo-path=PATH]
EOF
}

function custom_print_help_05_valetudo() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --valetudo-path=PATH       The path to Valetudo(https://github.com/Hypfer/Valetudo) to include it into the image
EOF
}

function custom_parse_args_05_valetudo() {
    case ${PARAM} in
        *-valetudo-path)
            VALETUDO_PATH="$ARG"
            if [ -r "${VALETUDO_PATH}/valetudo" ]; then
                ENABLE_VALETUDO=1
            else
                echo "The Valetudo binary hasn't been found in $VALETUDO_PATH"
                echo "Please download it from https://github.com/Hypfer/Valetudo"
                echo "(example: git clone https://github.com/Hypfer/Valetudo ../Valetudo && wget https://github.com/Hypfer/Valetudo/releases/latest/download/valetudo -O ../Valetudo/valetudo)"
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

function custom_function_05_valetudo() {
    if [ $ENABLE_VALETUDO -eq 1 ] && [ $ENABLE_DUMMYCLOUD -eq 1 ]; then
        echo "! You can't install Valetudo and Dummycloud at the same time, "
        echo "! because Valetudo has implemented Dummycloud fuctionality and map upload support now."
        cleanup_and_exit 1
    fi

    if [ $ENABLE_VALETUDO_RE -eq 1 ] && [ $ENABLE_VALETUDO -eq 1 ]; then
        echo "! You can't install Valetudo RE and Valetudo at the same time, "
        cleanup_and_exit 1
    fi

    if [ $ENABLE_VALETUDO -eq 1 ]; then
        echo "+ Installing Valetudo"

        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            install -m 0755  "${FILES_PATH}/S11valetudo" "${IMG_DIR}/etc/init/S11valetudo"
            install -D -m 0755  "${FILES_PATH}/valetudo-daemon.sh" "${IMG_DIR}/usr/local/bin/valetudo-daemon.sh"
        else
            if [ -f "${VALETUDO_PATH}/deployment/valetudo.conf" ]; then
                install -m 0644 "${VALETUDO_PATH}/deployment/valetudo.conf" "${IMG_DIR}/etc/init/valetudo.conf"
            else
                echo "!! ${VALETUDO_PATH}/deployment/valetudo.conf not found. Please download it."
                cleanup_and_exit 2
            fi
        fi

        install -D -m 0755 "${VALETUDO_PATH}/valetudo" "${IMG_DIR}/usr/local/bin/valetudo"

        if [ $ENABLE_DNS_CATCHER -ne 1 ]; then
            if [ -f "${VALETUDO_PATH}/deployment/etc/hosts" ]; then
                cat "${VALETUDO_PATH}/deployment/etc/hosts" >> "${IMG_DIR}/etc/hosts"
            else
                echo "!! ${VALETUDO_PATH}/deployment/etc/hosts not found. Please download it."
                cleanup_and_exit 2
            fi
        fi

        if [ -f "${VALETUDO_PATH}/deployment/etc/rc.local" ]; then
            sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
            cat "${VALETUDO_PATH}/deployment/etc/rc.local" >> "${IMG_DIR}/etc/rc.local"
            echo >> "${IMG_DIR}/etc/rc.local"
            echo "exit 0" >> "${IMG_DIR}/etc/rc.local"
        else
            echo "!! ${VALETUDO_PATH}/deployment/etc/rc.local not found. Please download it."
            cleanup_and_exit 2
        fi
    fi
}
