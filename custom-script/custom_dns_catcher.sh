#!/usr/bin/env bash
# Redirect and spoof outgoing dns requests(for xiaomi servers)
# dnsmasq and drill for tests

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_07_dns_catcher")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_07_dns_catcher")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_07_dns_catcher")
LIST_CUSTOM_FUNCTION+=("custom_function_07_dns_catcher")
ENABLE_DNS_CATCHER=${ENABLE_DNS_CATCHER:-"0"}

function custom_print_usage_07_dns_catcher() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-dns-catcher]
EOF
}

function custom_print_help_07_dns_catcher() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-dns-catcher       Redirect and spoof outgoing dns requests(for xiaomi servers)
EOF
}

function custom_parse_args_07_dns_catcher() {
    case ${PARAM} in
        *-enable-dns-catcher)
            ENABLE_DNS_CATCHER=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_07_dns_catcher() {
    if [ $ENABLE_DNS_CATCHER -eq 1 ]; then
        if [ -r "${FILES_PATH}/dns.tgz" ]; then
            echo "+ Installing dns-catcher"
            tar -C "$IMG_DIR" -xzf "${FILES_PATH}/dns.tgz"
            if [ ! -f "${IMG_DIR}/etc/inittab" ]; then
                rm "${IMG_DIR}/etc/init/S09xdnsmasq"
            fi
            sed -i 's/exit 0//' "${IMG_DIR}/etc/rc.local"
            cat << EOF >> "${IMG_DIR}/etc/rc.local"

### DNS CATCHER INIT ###
iptables -t nat -A OUTPUT -p udp -m owner ! --uid-owner nobody --dport 53 -j DNAT --to 127.0.0.1:55553
iptables -t nat -A OUTPUT -p tcp -m owner ! --uid-owner nobody --dport 53 -j DNAT --to 127.0.0.1:55553
### DNS CATCHER END ###

EOF
            echo "exit 0" >> "${IMG_DIR}/etc/rc.local"
        else
            echo "- ${FILES_PATH}/dns.tgz not found/readable"
        fi
    fi
}

