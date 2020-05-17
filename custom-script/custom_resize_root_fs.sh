#!/usr/bin/env bash
# Resize root fs (2008+)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_resize_root_fs")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_resize_root_fs")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_resize_root_fs")
LIST_CUSTOM_FUNCTION+=("custom_function_resize_root_fs")
RESIZE_ROOT_FS=${RESIZE_ROOT_FS:-"0"}

function custom_print_usage_resize_root_fs() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--resize-root-fs]
EOF
}

function custom_print_help_resize_root_fs() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --resize-root-fs           Resize root fs (2008+)
EOF
}

function custom_parse_args_resize_root_fs() {
    case ${PARAM} in
        *-resize-root-fs)
            RESIZE_ROOT_FS=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_resize_root_fs() {
    if [ $RESIZE_ROOT_FS -eq 1 ]; then
        if [ -f "${IMG_DIR}/etc/inittab" ]; then
            echo "+ Resize root fs(2008+)"
            sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
            echo "resize2fs /dev/root" >> "${IMG_DIR}/etc/rc.local"
            echo >> "${IMG_DIR}/etc/rc.local"
            echo "exit 0" >> "${IMG_DIR}/etc/rc.local"
		fi
    fi
}
