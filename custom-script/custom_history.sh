#!/bin/bash
# Add buildnumber to history file

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_history")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_history")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_history")
LIST_CUSTUM_FUNCTION+=("custom_function_history")

function custom_print_usage_history() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-history]
EOF
}

function custom_print_help_history() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-history           Add buildnumber to history file
EOF
}

function custom_parse_args_history() {
    case ${PARAM} in
        *-enable-history)
            ENABLE_HISTORY=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_history() {
    ENABLE_ADDON=${ENABLE_HISTORY:-"0"}

    if [ $ENABLE_HISTORY -eq 1 ]; then
        echo "+ Added buildnumber to history file"
        BUILD_NUMBER=`cat $IMG_DIR/opt/rockrobo/buildnumber | tr -d '\n'`
        echo "$FIRMWARE_BASENAME $BUILD_NUMBER" >> $BASEDIR/history.txt
        sort -u $BASEDIR/history.txt > $BASEDIR/history.txt.tmp
        mv $BASEDIR/history.txt.tmp $BASEDIR/history.txt
    fi
}
