#!/bin/bash
# Add greeting to ssh

LIST_CUSTOM_PRINT_USAGE+=("custom_print_usage_greeting")
LIST_CUSTOM_PRINT_HELP+=("custom_print_help_greeting")
LIST_CUSTOM_PARSE_ARGS+=("custom_parse_args_greeting")
LIST_CUSTOM_FUNCTION+=("custom_function_greeting")


function custom_print_usage_greeting() {
    cat << EOF

Custom parameters for '${BASH_SOURCE[0]}':
[--enable-greeting]
EOF
}

function custom_print_help_greeting() {
    cat << EOF

Custom options for '${BASH_SOURCE[0]}':
  --enable-greeting          Add greeting to ssh
EOF
}

function custom_parse_args_greeting() {
    case ${PARAM} in
        *-enable-greeting)
            ENABLE_GREETING=1
            ;;
        -*)
            return 1
            ;;
    esac
}

function custom_function_greeting() {
    ENABLE_GREETING=${ENABLE_GREETING:-"0"}

    if [ $ENABLE_GREETING -eq 1 ]; then
        echo "+ Adding Greetings"
        VERSION=$(date "+%Y%m%d")
        cat << EOF > "${IMG_DIR}/etc/profile.d/greeting.sh"
#!/bin/sh

SERIAL=\$(cat /dev/shm/sn | grep -ao '[[:alnum:]]*')
FIRMWARE=\$(cat /opt/rockrobo/rr-release | grep -E '^(ROBOROCK_VERSION|ROCKROBO_VERSION)'| cut -f2 -d=)
IP=\$(hostname -I)
TOKEN=\$(cat /mnt/data/miio/device.token | tr -d '\n' | xxd -p)
DID=\$(cat /mnt/default/device.conf | grep '^did' | cut -f2 -d=)
MAC=\$(cat /mnt/default/device.conf | grep '^mac' | cut -f2 -d=)
KEY=\$(cat /mnt/default/device.conf | grep '^key' | cut -f2 -d=)
MODEL=\$(cat /mnt/default/device.conf | grep '^model' | cut -f2 -d=)
BUILD_NUMBER=\$(cat /opt/rockrobo/buildnumber | tr -d '\n')
REGION=\$(cat /mnt/default/roborock.conf 2>/dev/null | grep location | cut -f2 -d'=')
P_YEAR="201"\$(echo \$SERIAL | cut -c 7)
P_WEEK=\$(echo \$SERIAL | cut -c 8-9)
P_DATE=\$(date -d "\$P_YEAR-01-01 +\$(( \$P_WEEK * 7 + 1 - \$(date -d "\$P_YEAR-01-04" +%w ) - 3 )) days -2 days" +"%B %Y")

echo
echo "          _______  _______                    _______ "
echo "|\     /|(  ___  )(  ____ \|\     /||\     /|(       )"
echo "| )   ( || (   ) || (    \/| )   ( || )   ( || () () |"
echo "| |   | || (___) || |      | |   | || |   | || || || |"
echo "( (   ) )|  ___  || |      | |   | || |   | || |(_)| |"
echo " \ \_/ / | (   ) || |      | |   | || |   | || |   | |"
echo "  \   /  | )   ( || (____/\| (___) || (___) || )   ( |"
echo "   \_/   |/     \|(_______/(_______)(_______)|/     \|"
printf "                                              \033[1;91m$VERSION\033[0m\n"
echo "======================================================"
printf "\033[1;36mMODEL\033[0m...........: \$MODEL\n"
printf "\033[1;36mSERIAL\033[0m..........: \$SERIAL\n"
printf "\033[1;36mPRODUCTION DATE\033[0m.: \$P_DATE\n"
printf "\033[1;36mFIRMWARE\033[0m........: \$FIRMWARE\n"
printf "\033[1;36mBUILD NUMBER\033[0m....: \$BUILD_NUMBER\n"
printf "\033[1;36mREGION\033[0m..........: \$REGION\n"
printf "\033[1;36mIP\033[0m..............: \$IP\n"
printf "\033[1;36mMAC\033[0m.............: \$MAC\n"
printf "\033[1;36mTOKEN\033[0m...........: \$TOKEN\n"
printf "\033[1;36mDID\033[0m.............: \$DID\n"
printf "\033[1;36mKEY\033[0m.............: \$KEY\n"
echo "======================================================"
echo
EOF
        chmod +x "${IMG_DIR}/etc/profile.d/greeting.sh"
    fi
}
