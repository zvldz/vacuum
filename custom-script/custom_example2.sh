#!/bin/bash
# Example 2

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_example2")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_example2")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_example2")
LIST_CUSTUM_FUNCTION+=("custom_function_example2")

function custom_print_usage_example2() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--example2 --param2=PARAM]
EOF
}

function custom_print_help_example2() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --example2                 Example2
  --param2=PARAM             Param2
EOF
}

function custom_parse_args_example2() {
    case ${PARAM} in
        *-example2)
            EXAMPLE2=1
            ;;
        *-param2)
            PARAM2="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_example2() {
    EXAMPLE2=${EXAMPLE2:-"0"}

    if [ $EXAMPLE2 -eq 1 ]; then
        echo "+ Start something 2"
    fi

    if [ -n "$PARAM2" ]; then
        echo "+ PARAM2 = $PARAM2"
    fi
}
