#!/usr/bin/env bash
# Install Valetudo RE (https://github.com/rand256/valetudo)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_05_valetudo_re")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_05_valetudo_re")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_05_valetudo_re")
LIST_CUSTOM_FUNCTION+=("custom_function_05_valetudo_re")
ENABLE_VALETUDO_RE=${ENABLE_VALETUDO_RE:-"0"}
VALETUDO_RE_NODEPS=${VALETUDO_RE_NODEPS:-"0"}

function custom_print_usage_05_valetudo_re() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--valetudo-re-path=PATH]
[--valetudo-re-nodeps]
EOF
}

function custom_print_help_05_valetudo_re() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --valetudo-re-path=PATH    The path to Valetudo RE(https://github.com/rand256/valetudo) to include it into the image
  --valetudo-re-nodeps       Do not add libstd++ dependencies if using binary built with partial static linking
EOF
}

function custom_parse_args_05_valetudo_re() {
    case ${PARAM} in
        *-valetudo-re-path)
            VALETUDO_RE_PATH="$ARG"
            if [ -r "${VALETUDO_RE_PATH}/valetudo" ]; then
                ENABLE_VALETUDO_RE=1
            else
                echo "The Valetudo RE binary hasn't been found in $VALETUDO_RE_PATH"
                echo "Please download it from https://github.com/rand256/valetudo"
                echo "example:
                        mkdir ../Valetudo_RE
                        cd ../Valetudo_RE
                        wget https://raw.githubusercontent.com/rand256/valetudo/testing/deployment/valetudo.conf
                        wget https://raw.githubusercontent.com/rand256/valetudo/testing/deployment/etc/rc.local
                        wget https://raw.githubusercontent.com/rand256/valetudo/testing/deployment/etc/hosts
                        wget https://github.com/rand256/valetudo/releases/latest/download/valetudo.tar.gz | tar xzf -
                "
                echo
                cleanup_and_exit 1
            fi
            CUSTOM_SHIFT=1
            ;;
        *-valetudo-re-nodeps)
            VALETUDO_RE_NODEPS=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_05_valetudo_re() {
    if [ $ENABLE_VALETUDO_RE -eq 1 ] && [ $ENABLE_DUMMYCLOUD -eq 1 ]; then
        echo "You can't install Valetudo RE and Dummycloud at the same time, "
        echo "because Valetudo RE has implemented Dummycloud fuctionality and map upload support now."
        cleanup_and_exit 1
    fi

    if [ $ENABLE_VALETUDO_RE -eq 1 ] && [ $ENABLE_VALETUDO -eq 1 ]; then
        echo "You can't install Valetudo RE and Valetudo at the same time, "
        cleanup_and_exit 1
    fi

    if [ $ENABLE_VALETUDO_RE -eq 1 ]; then
        echo "+ Installing Valetudo RE"
        if [ $VALETUDO_RE_NODEPS -ne 1 ]; then
            if [ -r "${FILES_PATH}/valetudo_re_deps.tgz" ]; then
                echo "+ Unpacking of Valetudo RE dependencies"
                tar -C "${IMG_DIR}" -xzf "${FILES_PATH}/valetudo_re_deps.tgz"
            else
                echo "!! ${FILES_PATH}/valetudo_re_deps.tgz not found/readable"
            fi
        fi

        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            install -m 0755  "${FILES_PATH}/valetudo/S11valetudo" "${IMG_DIR}/etc/init/S11valetudo"
            install -D -m 0755  "${FILES_PATH}/valetudo/valetudo-daemon.sh" "${IMG_DIR}/usr/local/bin/valetudo-daemon.sh"
        else
            if [ -f "${VALETUDO_RE_PATH}/valetudo.conf" ]; then
                install -m 0644 "${VALETUDO_RE_PATH}/valetudo.conf" "${IMG_DIR}/etc/init/valetudo.conf"
            else
                echo "!! ${VALETUDO_RE_PATH}/valetudo.conf not found. Please download it."
                cleanup_and_exit 2
            fi
        fi

        install -D -m 0755 "${VALETUDO_RE_PATH}/valetudo" "${IMG_DIR}/usr/local/bin/valetudo"

        if [ $ENABLE_DNS_CATCHER -ne 1 ]; then
            if [ -f "${VALETUDO_RE_PATH}/hosts" ]; then
                cat "${VALETUDO_RE_PATH}/hosts" >> "${IMG_DIR}/etc/hosts"
            else
                echo "!! ${VALETUDO_RE_PATH}/hosts not found. Please download it."
                cleanup_and_exit 2
            fi
        fi

        if [ -f "${VALETUDO_RE_PATH}/rc.local" ]; then
            sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
            cat "${VALETUDO_RE_PATH}/rc.local" >> "${IMG_DIR}/etc/rc.local"
            echo >> "${IMG_DIR}/etc/rc.local"
            echo "exit 0" >> "${IMG_DIR}/etc/rc.local"
        else
            echo "!! ${VALETUDO_RE_PATH}/rc.local not found. Please download it."
            cleanup_and_exit 2
        fi
    fi
}
