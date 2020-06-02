#!/usr/bin/env bash
# Replace xiaomis custom adbd with generic adbd version

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_01_adbd")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_01_adbd")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_01_adbd")
LIST_CUSTOM_FUNCTION+=("custom_function_01_adbd")
PATCH_ADBD=${PATCH_ADBD:-"0"}

function custom_print_usage_01_adbd() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--replace-adbd]
EOF
}

function custom_print_help_01_adbd() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --replace-adbd             Replace xiaomis custom adbd with generic adbd version
EOF
}

function custom_parse_args_01_adbd() {
    case ${PARAM} in
        *-replace-adbd)
            PATCH_ADBD=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_01_adbd() {
    if [ $PATCH_ADBD -eq 1 ]; then
        if [ -r "${FILES_PATH}/adbd" ]; then
            echo "+ Replacing adbd"
            install -m 0755 "${FILES_PATH}/adbd" "${IMG_DIR}/usr/bin/adbd"
        else
            echo "- ${FILES_PATH}/adbd not found/readable, cannot replace adbd in image"
        fi
    fi
}
