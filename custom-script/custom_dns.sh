#!/bin/bash

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_dns")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_dns")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_dns")
LIST_CUSTUM_FUNCTION+=("custom_function_dns")

function custom_print_usage_dns()
{
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--dnsserver=ADDRESS]
EOF
}

function custom_print_help_dns()
{
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --dnsserver=ADDRESS        Set your DNS server (ex: "8.8.8.8, 1.1.1.1")
EOF
}

function custom_parse_args_dns()
{
    case ${PARAM} in
        *-dnsserver)
            DNSSERVER="$ARG"
            CUSTOM_SHIFT=1
            ;;
        -*)
            return -1
            ;;
    esac
}

function custom_function_dns()
{
    if [ -n "$DNSSERVER" ]; then
        echo "+ Replacing DNS servers"
        sed -i -E "s/.*reject.*/supersede domain-name-servers $DNSSERVER;/" $IMG_DIR/etc/dhcp/dhclient.conf
    fi
}
