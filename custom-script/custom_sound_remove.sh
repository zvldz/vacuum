#!/usr/bin/env bash
# Removes extra sound files to gain space (prc, tw and testing samples)

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_cleanup_sound")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_cleanup_sound")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_cleanup_sound")
LIST_CUSTOM_FUNCTION+=("custom_function_cleanup_sound")
CLEANUP_SOUNDFILES=${CLEANUP_SOUNDFILES:-"0"}

function custom_print_usage_cleanup_sound() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--remove-extra-sounds]
EOF
}

function custom_print_help_cleanup_sound() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --remove-extra-sounds      Removes extra sound files to gain space (prc, tw and testing samples).
EOF
}

function custom_parse_args_cleanup_sound() {
    case ${PARAM} in
        *-remove-extra-sounds)
            CLEANUP_SOUNDFILES=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_cleanup_sound() {
    TO_REMOVE=('sounds/mtest' 'sounds/prc' 'sounds/tw' 'sounds/Facsounds/prc')
    SOUNDS_FOLDER="${IMG_DIR}/opt/rockrobo/resources"

    if [ $CLEANUP_SOUNDFILES -eq 1 ]; then
        for pack in "${TO_REMOVE[@]}"; do
            echo "+ Remove $pack"
            rm -r "${SOUNDS_FOLDER}/${pack}"
        done
    fi
}
