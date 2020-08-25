#!/usr/bin/env bash
# Install oucher (https://github.com/porech/roborock-oucher)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_oucher")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_oucher")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_oucher")
LIST_CUSTOM_FUNCTION+=("custom_function_01_oucher")
ENABLE_OUCHER=${ENABLE_OUCHER:-"0"}

function custom_print_usage_01_oucher() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-oucher]
EOF
}

function custom_print_help_01_oucher() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-oucher            Enable 'oucher' (https://github.com/porech/roborock-oucher)
EOF
}

function custom_parse_args_01_oucher() {
    case ${PARAM} in
        *-enable-oucher)
            ENABLE_OUCHER=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_oucher() {
    if [ $ENABLE_OUCHER -eq 1 ]; then
        echo "+ Installing oucher (https://github.com/porech/roborock-oucher)"

        install -D -m 0755 "${FILES_PATH}/oucher/oucher" "${IMG_DIR}/usr/local/bin/oucher"
        install -m 0644 "${FILES_PATH}/oucher/oucher.yml" "${IMG_DIR}/root/oucher.yml"
        tar -C "${IMG_DIR}" -xzf "${FILES_PATH}/oucher/oucher_deps.tgz"
        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            install -m 0755  "${FILES_PATH}/oucher/S12oucher" "${IMG_DIR}/etc/init/S12oucher"
        else
            install -m 0644 "${FILES_PATH}/oucher/oucher.conf" "${IMG_DIR}/etc/init/oucher.conf"
        fi

        if [ "$ENABLE_ADDON_SOX" -eq 0 ]; then
            echo "!! 'oucher' requires a SoX. Set it manually or add '--enable-addon-sox'"
            cleanup_and_exit 2
        fi
    fi
}
