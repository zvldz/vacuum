#!/usr/bin/env bash
# https://dustbuilder.xvm.mit.edu/resetfix_maybe/

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_fixreset")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_fixreset")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_fixreset")
LIST_CUSTOM_FUNCTION+=("custom_function_fixreset")
FIX_RESET=${FIX_RESET:-"0"}

function custom_print_usage_fixreset() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--fix-reset]
EOF
}

function custom_print_help_fixreset() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --fix-reset                Apply firmware reset fix
EOF
}

function custom_parse_args_fixreset() {
    case ${PARAM} in
        *-fix-reset)
            FIX_RESET=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_fixreset() {
    if [ $FIX_RESET -eq 1 ]; then
        echo "+ Running reset fix"
        if [ -f "./etc/inittab" ]; then
        echo "++ OpenWRT mode"
            cp ${FILES_PATH}/cleanflags.sh ${IMG_DIR}/sbin/
            chmod a+x ${IMG_DIR}/sbin/cleanflags.sh
            install -m 0755 ${FILES_PATH}/S10cleanflags ${IMG_DIR}/etc/init/S10cleanflags
            else
        echo "++ Ubuntu mode"
            install -m 0755 ${FILES_PATH}/cleanflags.sh ${IMG_DIR}/sbin/
            install -m 0755 ${FILES_PATH}/S20cleanflags ${IMG_DIR}/etc/init.d/cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc0.d/K20cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc1.d/K20cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc6.d/K20cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc2.d/S20cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc3.d/S20cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc4.d/S20cleanflags
            ln -sr ${IMG_DIR}/etc/init.d/cleanflags ${IMG_DIR}/etc/rc5.d/S20cleanflags
        fi
    fi
}
