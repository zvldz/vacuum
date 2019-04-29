#!/bin/bash
# Install custom sound files

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_sound")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_sound")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_sound")
LIST_CUSTUM_FUNCTION+=("custom_function_sound")

function custom_print_usage_sound()
{
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--soundfile=english.pkg]
EOF
}

function custom_print_help_sound()
{
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  -s, --soundfile=PATH       Path to sound file
EOF
}

function custom_parse_args_sound()
{
    case ${PARAM} in
        *-soundfile|-s)
            SOUNDFILE_PATH="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_sound()
{
    SOUNDLANG=${SOUNDLANG:-"en"}
    PASSWORD_SND="r0ckrobo#23456"

    if [ -n "$SOUNDFILE_PATH" ]; then
        SOUNDFILE_PATH=$(readlink_f "$SOUNDFILE_PATH")
    fi

    if [ -n "$SOUNDFILE_PATH" ]; then
        echo "+ Decrypt soundfile .."
        SND_DIR="$FW_TMPDIR/sounds"
        SND_FILE=$(basename $SOUNDFILE_PATH)
        mkdir -p $SND_DIR
        cp "$SOUNDFILE_PATH" "$SND_DIR/$SND_FILE"
        $CCRYPT -d -K "$PASSWORD_SND" "$SND_DIR/$SND_FILE"

        echo "+ Unpack soundfile .."
        pushd "$SND_DIR"
        tar -xzf "$SND_FILE"
        popd
    fi

    if [ -n "$SND_DIR" ]; then
        SND_DST_DIR="$IMG_DIR/opt/rockrobo/resources/sounds/${SOUNDLANG}"
        install -d -m 0755 $SND_DST_DIR

        # Add sounds for a specific language
        for f in ${SND_DIR}/*.wav; do
            install -m 0644 $f ${SND_DST_DIR}/$(basename ${f})
        done
    fi
}
