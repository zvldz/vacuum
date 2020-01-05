#!/bin/bash
# Example 1

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_example1")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_example1")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_example1")
LIST_CUSTOM_FUNCTION+=("custom_function_example1")
EXAMPLE1=${EXAMPLE1:-"0"}

function custom_print_usage_example1() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--example1 --param1=PARAM]
EOF
}

function custom_print_help_example1() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --example1                 Example1
  --param1=PARAM             Param1
EOF
}

function custom_parse_args_example1() {
    case ${PARAM} in
        *-example1)
            EXAMPLE1=1
            ;;
        *-param1)
            PARAM1="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_example1() {
    if [ $EXAMPLE1 -eq 1 ]; then
        echo "+ Start something 1"
    fi

    if [ -n "$PARAM1" ]; then
        echo "+ PARAM1 = $PARAM1"
    fi
}
