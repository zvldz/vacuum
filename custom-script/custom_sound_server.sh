#!/usr/bin/env bash
# Install sound server
# Based on the article https://habr.com/ru/post/435064/

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_sound_server")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_sound_server")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_sound_server")
LIST_CUSTOM_FUNCTION+=("custom_function_01_sound_server")
ENABLE_SOUND_SERVER=${ENABLE_SOUND_SERVER:-"0"}

function custom_print_usage_01_sound_server() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-sound-server]
EOF
}

function custom_print_help_01_sound_server() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-sound-server  Enable playing sounds over network

Example of usage (python3):
  import socket
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.connect((%ip%, 7777))
  s.sendall(b'http://%local_ip%:%local_port%/test.mp3;')
  s.close()
EOF
}

function custom_parse_args_01_sound_server() {
    case ${PARAM} in
        *-enable-sound-server)
            ENABLE_SOUND_SERVER=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_sound_server() {
    if [ $ENABLE_SOUND_SERVER -eq 1 ]; then
        echo "+ Installing sound server"

        install -D -m 0755 "${FILES_PATH}/sound_server/sound_server.pl" "${IMG_DIR}/usr/local/bin/sound_server.pl"
        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            install -m 0755  "${FILES_PATH}/sound_server/S12soundserver" "${IMG_DIR}/etc/init/S12soundserver"
            tar -C "${IMG_DIR}" -xzf "${FILES_PATH}/sound_server/perl.tgz"
        else
            install -m 0644 "${FILES_PATH}/sound_server/soundserver.conf" "${IMG_DIR}/etc/init/soundserver.conf"
        fi

        if [ "$ENABLE_ADDON_SOX" -eq 0 ]; then
            echo "!! 'sound-server' requires a sox. Set it manually or add '--enable-addon-sox'"
            cleanup_and_exit 2
        fi
    fi
}
