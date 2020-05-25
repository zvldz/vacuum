#!/usr/bin/env bash
# Xiaomi Vacuum v1/2 begins to talk random phrases when cleaning
# Author: .//Hack (Alexander Krylov)
# Site: https://4pda.ru/forum/index.php?showtopic=881982&st=8100#entry92139228

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_random_phrases")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_random_phrases")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_random_phrases")
LIST_CUSTOM_FUNCTION+=("custom_function_random_phrases")
ENABLE_RANDOM_PHRASES=${ENABLE_RANDOM_PHRASES:-"0"}
RANDOM_PHRASES_CRON=${RANDOM_PHRASES_CRON:-"* * * * *"}

function custom_print_usage_random_phrases() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-random-phrases|--random-phrases-cron=CRON]
EOF
}

function custom_print_help_random_phrases() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-random-phrases           Adding random phrases when cleaning
  --random-phrases-cron=CRON        Set own cron schedule for random phrases (default: * * * * *)
EOF
}

function custom_parse_args_random_phrases() {
    case ${PARAM} in
        *-enable-random-phrases)
            ENABLE_RANDOM_PHRASES=1
            ;;
        *-random-phrases-cron)
            RANDOM_PHRASES_CRON="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_random_phrases() {
    if [ $ENABLE_RANDOM_PHRASES -eq 1 ]; then
        if [ -r "${FILES_PATH}/phrases.sh" ]; then
            echo "+ Installing random phrases when cleaning"
            install -D -m 0755  "${FILES_PATH}/phrases.sh" "${IMG_DIR}/usr/local/bin/phrases.sh"

            if [ $ENABLE_ADDON_SOX -eq 0 ]; then
                echo "!! 'random-phrases' requires a sox. Set it manually or add '--enable-addon-sox'"
                 cleanup_and_exit 2
            fi
        else
            echo "-- ${FILES_PATH}/phrases.sh not found/readable"
        fi
    fi
}
