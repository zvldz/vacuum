#!/bin/bash
# Patch rrlogd to disable log encryption

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_rrlogd_patcher")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_rrlogd_patcher")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_rrlogd_patcher")
LIST_CUSTUM_FUNCTION+=("custom_function_rrlogd_patcher")

function custom_print_usage_rrlogd_patcher() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--rrlogd-patcher=PATCHER]
EOF
}

function custom_print_help_rrlogd_patcher() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --rrlogd-patcher=PATCHER   Patch rrlogd to disable log encryption (only use with dummycloud or dustcloud)
EOF
}

function custom_parse_args_rrlogd_patcher() {
    case ${PARAM} in
        *-rrlogd-patcher)
            PATCH_RRLOGD=1
            RRLOGD_PATCHER="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_rrlogd_patcher() {
    PATCH_RRLOGD=${PATCH_RRLOGD:-"0"}

    if [ $PATCH_RRLOGD -eq 1 ]; then
        PYTHON=${PYTHON:-"python3"}
        RRLOGD_PATCHER_ABS="$(readlink_f $RRLOGD_PATCHER 2> /dev/null)"

        if [ -r "$RRLOGD_PATCHER_ABS" ]; then
            echo "+ Creating backup of rrlogd"
            cp $IMG_DIR/opt/rockrobo/rrlog/rrlogd $IMG_DIR/opt/rockrobo/rrlog/rrlogd.xiaomi

            # This is a extremly simple binary patch by John Rev
            # In the long run we should use his rrlogd-patcher however we would need to integrate
            # it into the imagebuilder package or git repo.
            #
            # See https://github.com/JohnRev/rrlogd-patcher
            echo "+ Trying to patch rrlogd"
            cp $IMG_DIR/opt/rockrobo/rrlog/rrlogd $FW_TMPDIR/rrlogd

            pushd $FW_TMPDIR
            $PYTHON "$RRLOGD_PATCHER_ABS"
            ret=$?
            popd
            if [ $ret -eq 0 ]; then
                install -m 0755 $FW_TMPDIR/rrlogd_patch $IMG_DIR/opt/rockrobo/rrlog/rrlogd
                echo "+ Successfully patched rrlogd"
            else
                echo "! Failed to patch rrlogd (please report a bug here: https://github.com/JohnRev/rrlogd-patcher/issues)"
            fi
        else
            echo "! Invalid path to rrlogd ($RRLOGD_PATCHER_ABS)"
        fi
    fi
}
