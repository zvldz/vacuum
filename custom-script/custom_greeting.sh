#!/bin/bash

LIST_CUSTUM_FUNCTION+=("custom_function_greeting")

function custom_function_greeting()
{
    echo "+ Adding Greetings"
    VERSION=`date "+%Y%m%d"`
    cat << EOF > $IMG_DIR/etc/profile.d/greeting.sh
#!/bin/sh

FIRMWARE=\`cat /etc/os-release | grep '^ROBOROCK_VERSION' | cut -f2 -d=\`
IP=\`hostname -I\`
TOKEN=\`cat /mnt/data/miio/device.token | tr -d '\n' | xxd -p\`
DID=\`cat /mnt/default/device.conf | grep '^did' | cut -f2 -d=\`
MAC=\`cat /mnt/default/device.conf | grep '^mac' | cut -f2 -d=\`
KEY=\`cat /mnt/default/device.conf | grep '^key' | cut -f2 -d=\`
MODEL=\`cat /mnt/default/device.conf | grep '^model' | cut -f2 -d=\`
BUILD_NUMBER=\`cat /opt/rockrobo/buildnumber | tr -d '\n'\`

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
printf "\033[1;36mMODEL\033[0m.........: \$MODEL\n"
printf "\033[1;36mFIRMWARE\033[0m......: \$FIRMWARE\n"
printf "\033[1;36mBUILD NUMBER\033[0m..: \$BUILD_NUMBER\n"
printf "\033[1;36mIP\033[0m............: \$IP\n"
printf "\033[1;36mMAC\033[0m...........: \$MAC\n"
printf "\033[1;36mTOKEN\033[0m.........: \$TOKEN\n"
printf "\033[1;36mDID\033[0m...........: \$DID\n"
printf "\033[1;36mKEY\033[0m...........: \$KEY\n"
echo "======================================================"
echo
EOF
    chmod +x $IMG_DIR/etc/profile.d/greeting.sh
}
