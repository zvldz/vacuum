#!/bin/bash
# Install Valetudo RE (https://github.com/rand256/valetudo)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_valetudo_re")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_valetudo_re")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_valetudo_re")
LIST_CUSTOM_FUNCTION+=("custom_function_valetudo_re")

function custom_print_usage_valetudo_re() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--valetudo-re-path=PATH]
EOF
}

function custom_print_help_valetudo_re() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --valetudo-re-path=PATH    The path to Valetudo RE(https://github.com/rand256/valetudo) to include it into the image
EOF
}

function custom_parse_args_valetudo_re() {
    case ${PARAM} in
        *-valetudo-re-path)
            VALETUDO_RE_PATH="$ARG"
            if [ -r "$VALETUDO_RE_PATH/valetudo" ]; then
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
                        wget https://github.com/rand256/valetudo/releases/download/0.4.0-RE7/valetudo.tar.gz -O- | tar xzf -
                "
                echo
                cleanup_and_exit 1
            fi
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_valetudo_re() {
    ENABLE_VALETUDO=${ENABLE_VALETUDO:-"0"}
    ENABLE_VALETUDO_RE=${ENABLE_VALETUDO_RE:-"0"}
    ENABLE_DUMMYCLOUD=${ENABLE_DUMMYCLOUD:-"0"}

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

        VALETUDO_RE_DEPS_PATH=$(dirname $(readlink_f ${BASH_SOURCE[0]}))
        if [ -r "$VALETUDO_RE_DEPS_PATH/valetudo_re_deps.tgz" ]; then
            echo "+ Unpacking of Valetudo RE dependencies"
            tar -C $IMG_DIR -xzf $VALETUDO_RE_DEPS_PATH/valetudo_re_deps.tgz
        else
            echo "- $VALETUDO_RE_DEPS_PATH/valetudo_re_deps.tgz not found/readable"
        fi

        install -m 0755 $VALETUDO_RE_PATH/valetudo $IMG_DIR/usr/local/bin/valetudo
        install -m 0644 $VALETUDO_RE_PATH/valetudo.conf $IMG_DIR/etc/init/valetudo.conf

        cat $VALETUDO_RE_PATH/hosts >> $IMG_DIR/etc/hosts

        sed -i 's/exit 0//' $IMG_DIR/etc/rc.local
        cat $VALETUDO_RE_PATH/rc.local >> $IMG_DIR/etc/rc.local
        echo >> $IMG_DIR/etc/rc.local
        echo "exit 0" >> $IMG_DIR/etc/rc.local

        # UPLOAD_METHOD=2
        sed -i -E 's/(UPLOAD_METHOD=)([0-9]+)/\12/' $IMG_DIR/opt/rockrobo/rrlog/rrlog.conf
        sed -i -E 's/(UPLOAD_METHOD=)([0-9]+)/\12/' $IMG_DIR/opt/rockrobo/rrlog/rrlogmt.conf

        # Set LOG_LEVEL=3
        sed -i -E 's/(LOG_LEVEL=)([0-9]+)/\13/' $IMG_DIR/opt/rockrobo/rrlog/rrlog.conf
        sed -i -E 's/(LOG_LEVEL=)([0-9]+)/\13/' $IMG_DIR/opt/rockrobo/rrlog/rrlogmt.conf

        # Reduce logging of miio_client
        sed -i 's/-l 2/-l 0/' $IMG_DIR/opt/rockrobo/watchdog/ProcessList.conf

        # Let the script cleanup logs
        sed -i 's/nice.*//' $IMG_DIR/opt/rockrobo/rrlog/tar_extra_file.sh

        # Disable collecting device info to /dev/shm/misc.log
        sed -i '/^\#!\/bin\/bash$/a exit 0' $IMG_DIR/opt/rockrobo/rrlog/misc.sh

        # Disable logging of 'top'
        sed -i '/^\#!\/bin\/bash$/a exit 0' $IMG_DIR/opt/rockrobo/rrlog/toprotation.sh
        sed -i '/^\#!\/bin\/bash$/a exit 0' $IMG_DIR/opt/rockrobo/rrlog/topstop.sh
    fi
}
