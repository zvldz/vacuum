#!/usr/bin/env bash
# Adding keys for ssh authentication

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_ssh_keys")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_ssh_keys")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_ssh_keys")
LIST_CUSTOM_FUNCTION+=("custom_function_ssh_keys")

function custom_print_usage_ssh_keys() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--public-key=id_rsa.pub]
EOF
}

function custom_print_help_ssh_keys() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  -k, --public-key=PATH      Path to ssh public key to be added to authorized_keys file
                             if need to add multiple keys set -k as many times as you need:
                             -k ./local_key.pub -k ~/.ssh/id_rsa.pub -k /root/ssh/id_rsa.pub
EOF
}

function custom_parse_args_ssh_keys() {
    case ${PARAM} in
        *-public-key|-k)
            # check if the key file exists
            if [ -r "$ARG" ]; then
                PUBLIC_KEYS[${#PUBLIC_KEYS[*]} + 1]=$(readlink -f "$ARG")
            else
                echo "Public key $ARG doesn't exist or is not readable"
                cleanup_and_exit 1
            fi
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_ssh_keys() {
    if [ -r "${IMG_DIR}/root/.ssh/authorized_keys" ]; then
        echo "+ Removing obsolete authorized_keys from Xiaomi image"
        rm "${IMG_DIR}/root/.ssh/authorized_keys"
    fi

    if [ ${#PUBLIC_KEYS[*]} -ne 0 ]; then
        echo "+ Add SSH authorized_keys"
        mkdir -p "${IMG_DIR}/root/.ssh"
        chmod 700 "${IMG_DIR}/root/.ssh"

        for i in $(eval echo {1..${#PUBLIC_KEYS[*]}}); do
            cat "${PUBLIC_KEYS[$i]}" >> "${IMG_DIR}/root/.ssh/authorized_keys"
        done
        chmod 600 "${IMG_DIR}/root/.ssh/authorized_keys"
    fi
}
