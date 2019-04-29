#!/bin/bash
# Installing valetudo without dummycloud

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_valetudo_wo_dummycloud")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_valetudo_wo_dummycloud")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_valetudo_wo_dummycloud")
LIST_CUSTUM_FUNCTION+=("custom_function_valetudo_wo_dummycloud")

function custom_print_usage_valetudo_wo_dummycloud()
{
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--valetudo-path-wod=PATH]
EOF
}

function custom_print_help_valetudo_wo_dummycloud()
{
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --valetudo-path-wod=PATH   The path to valetudo(without dummycloud) to include it into the image
EOF
}

function custom_parse_args_valetudo_wo_dummycloud()
{
    case ${PARAM} in
        *-valetudo-path-wod)
            VALETUDO_PATH_WOD="$ARG"
            if [ -r "$VALETUDO_PATH_WOD/valetudo" ]; then
                ENABLE_VALETUDO_WOD=1
            else
                echo "The valetudo binary hasn't been found in $VALETUDO_PATH_WOD"
                cleanup_and_exit 1
            fi
            CUSTOM_SHIFT=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_valetudo_wo_dummycloud()
{
    ENABLE_VALETUDO_WOD=${ENABLE_VALETUDO_WOD:-"0"}

    if [ $ENABLE_VALETUDO_WOD -eq 1 ]; then
        echo "+ Installing valetudo without dummycloud"
        install -m 0755 $VALETUDO_PATH_WOD/valetudo $IMG_DIR/usr/local/bin/valetudo
        install -m 0644 $VALETUDO_PATH_WOD/deployment/valetudo.conf $IMG_DIR/etc/init/valetudo.conf
    fi
}
