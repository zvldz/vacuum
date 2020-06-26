#!/usr/bin/env bash
# Original Author: Dennis Giese [dgiese@dontvacuum.me]
# Copyright 2017 by Dennis Giese
#
# Modified by zvldz

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program. If not, see <http://www.gnu.org/licenses/>.
#

function umount_image() {
    while [ $(umount "$IMG_DIR"; echo $?) -ne 0 ]; do
       echo "waiting for unmount..."
       sleep 2
    done

    if [ -d "${IMG_DIR}.org" ]; then
        while [ $(umount "${IMG_DIR}.org"; echo $?) -ne 0 ]; do
           echo "waiting for unmount..."
           sleep 2
       done
    fi
}

function cleanup_and_exit() {
    if [ "$1" = 0 ] || [ -z "$1" ]; then
        if [ -d "$FW_TMPDIR" ]; then
            rm -rf "$FW_TMPDIR"
        fi
        exit 0
    else
        echo "Cleaning up"
        if mountpoint -q "$IMG_DIR"; then
            umount_image
        fi
        rm -rf "$FW_TMPDIR"
        exit $1
    fi
}

function custom_print_usage() {
    LIST_CUSTOM_PRINT_USAGE=($(printf "%s\n" "${LIST_CUSTOM_PRINT_USAGE[@]}" | sort -u))
    for FUNC in "${LIST_CUSTOM_PRINT_USAGE[@]}"; do
        $FUNC
    done
}

function custom_print_help() {
    LIST_CUSTOM_PRINT_HELP=($(printf "%s\n" "${LIST_CUSTOM_PRINT_HELP[@]}" | sort -u))
    for FUNC in "${LIST_CUSTOM_PRINT_HELP[@]}"; do
        $FUNC
    done
}

function custom_parse_args() {
    LIST_CUSTOM_PARSE_ARGS=($(printf "%s\n" "${LIST_CUSTOM_PARSE_ARGS[@]}" | sort -u))
    for FUNC in "${LIST_CUSTOM_PARSE_ARGS[@]}"; do
        $FUNC && return 0
    done
}

function custom_function() {
    LIST_CUSTOM_FUNCTION=($(printf "%s\n" "${LIST_CUSTOM_FUNCTION[@]}" | sort -u))
    for FUNC in "${LIST_CUSTOM_FUNCTION[@]}"; do
        $FUNC
    done
}

function print_usage() {
    echo "Usage: sudo ./$(basename $0) --firmware=v11_003194.pkg [--unpack-and-mount|--resize-root-fs=FS_SIZE|--diff|--run-custom-script=SCRIPT|--help]"
    custom_print_usage
}

function print_help() {
    cat << EOF

Options:
  -h, --help                 Prints this message
  -f, --firmware=PATH        Path to firmware file
  --unpack-and-mount         Only unpack and mount image
  --resize-root-fs=FS_SIZE   Resize root fs to FS_SIZE.
  --diff                     Create diff between original and modified image.
                             This will temporarily take up more disk space.
  --run-custom-script=SCRIPT Run custom script (if 'ALL' run all scripts from custom-script)

Each parameter that takes a file as an argument accepts path in any form

Report bugs to: https://github.com/zvldz/vacuum/issues
Original Author: Dennis Giese [dgiese@dontvacuum.me], https://github.com/dgiese/dustcloud
EOF
    custom_print_help
}

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$0")
OUTDIR="${BASEDIR}/output"
CUSTOM_PATH="${BASEDIR}/custom-script"
FILES_PATH="${CUSTOM_PATH}/files"
UNPACK_AND_MOUNT=0
ENABLE_DIFF=0
LIST_CUSTOM_PRINT_USAGE=()
LIST_CUSTOM_PRINT_HELP=()
LIST_CUSTOM_PARSE_ARGS=()
LIST_CUSTOM_FUNCTION=()
CUSTOM_SHIFT=0

while [ -n "$1" ]; do
    PARAM="$1"
    ARG="$2"
    shift
    case ${PARAM} in
        *-*=*)
            ARG=${PARAM#*=}
            PARAM=${PARAM%%=*}
            set -- "----noarg=${PARAM}" "$@"
    esac
    case ${PARAM} in
        *-help|-h)
            print_usage
            print_help
            cleanup_and_exit
            ;;
        *-firmware|-f)
            FIRMWARE_PATH="$ARG"
            shift
            ;;
        *-unpack-and-mount)
            UNPACK_AND_MOUNT=1
            ;;
        *-resize-root-fs)
            RESIZE_ROOT_FS="$ARG"
            if [[ ! $RESIZE_ROOT_FS =~ ^[0-9]+$ ]]; then
                echo "$RESIZE_ROOT_FS is not numeric"
                cleanup_and_exit 1
            fi
            shift
            ;;
        *-diff)
            ENABLE_DIFF=1
            ;;
        *-run-custom-script)
            CUSTOM_SCRIPT="$ARG"
            if [ "$CUSTOM_SCRIPT" = "ALL" ]; then
                for FILE in ${CUSTOM_PATH}/custom*.sh; do
                    . $FILE
                done
            elif [ -r "$CUSTOM_SCRIPT" ]; then
                . $CUSTOM_SCRIPT
            else
                echo "The custom script hasn't been found ($CUSTOM_SCRIPT)"
                cleanup_and_exit 1
            fi
            shift
            ;;
        ----noarg)
            echo "$ARG does not take an argument"
            cleanup_and_exit
            ;;
        -*)
            if custom_parse_args $PARAM $ARG; then
                if [ $CUSTOM_SHIFT -eq 1 ]; then
                    shift
                    CUSTOM_SHIFT=0
                fi
            else
                echo Unknown Option "$PARAM". Exit.
                cleanup_and_exit 1
            fi
            ;;
        *)
            echo "PARAM=$PARAM"
            print_usage
            cleanup_and_exit 1
            ;;
    esac
done

if [ $EUID -ne 0 ]; then
    echo "You need root privileges to execute this script"
    cleanup_and_exit 1
fi

if [[ $OSTYPE == darwin* ]]; then
    echo "Does not work on OSX. Fuse-ext2 is broken and does not work well."
    cleanup_and_exit 1
fi

CCRYPT="$(type -p ccrypt)"
if [ ! -x "$CCRYPT" ]; then
    echo "ccrypt not found! Please install it (e.g. by (apt|dnf|zypper) install ccrypt)"
    cleanup_and_exit 1
fi

PASSWORD_FW="rockrobo"

if [ ! -r "$FIRMWARE_PATH" ]; then
    echo "You need to specify an existing firmware file, e.g. v11_003194.pkg"
    cleanup_and_exit 1
fi

FIRMWARE_PATH=$(readlink -f "$FIRMWARE_PATH")
FIRMWARE_BASENAME=$(basename "$FIRMWARE_PATH")
FIRMWARE_FILENAME="${FIRMWARE_BASENAME%.*}"

FW_TMPDIR="$(pwd)/$(mktemp -d fw.XXXXXX)"

echo "Decrypt firmware"
FW_DIR="${FW_TMPDIR}/fw"
mkdir -p "$FW_DIR"
cp "$FIRMWARE_PATH" "${FW_DIR}/$FIRMWARE_FILENAME"
$CCRYPT -d -K "$PASSWORD_FW" "${FW_DIR}/$FIRMWARE_FILENAME"

echo "Unpack firmware"
tar -C "$FW_DIR" -xzf "${FW_DIR}/$FIRMWARE_FILENAME"
if [ ! -r "${FW_DIR}/disk.img" ]; then
    echo "File ${FW_DIR}/disk.img not found! Decryption and unpacking was apparently unsuccessful."
    cleanup_and_exit 1
fi

IMG_DIR="${FW_TMPDIR}/image"
mkdir -p "$IMG_DIR"

if [ -n "$RESIZE_ROOT_FS" ]; then
    echo "+ Resize partition to $RESIZE_ROOT_FS"
    e2fsck -pf "${FW_DIR}/disk.img"
    resize2fs "${FW_DIR}/disk.img" $RESIZE_ROOT_FS
fi

mount -o loop "${FW_DIR}/disk.img" "$IMG_DIR"
if [ $? -ne 0 ]; then
    cleanup_and_exit 1
fi

if [ $UNPACK_AND_MOUNT -eq 1 ]; then
    echo "Image mounted to $IMG_DIR"
    echo "Run 'umount $IMG_DIR' for unmount the image"
    exit 0
fi

if [ $ENABLE_DIFF -eq 1 ]; then
    cp "${FW_DIR}/disk.img" "${FW_DIR}/disk.img.org"
fi

if [ -r "${IMG_DIR}/opt/rockrobo/rr-release" ]; then
    FW_VER=$(cat "${IMG_DIR}/opt/rockrobo/rr-release" | grep -E '^(ROBOROCK_VERSION|ROCKROBO_VERSION)' | cut -f2 -d= | cut -f2 -d_ | sed -E 's/^0+//')
elif [ -r "${IMG_DIR}/etc/os-release" ]; then
    FW_VER=$(cat "${IMG_DIR}/etc/os-release" | grep -E '^(ROBOROCK_VERSION|ROCKROBO_VERSION)' | cut -f2 -d= | cut -f2 -d_ | sed -E 's/^0+//')
else
    FW_VER=0
fi

echo "+ Generate SSH Host Keys if necessary"
if [ ! -r "${BASEDIR}/ssh_host_rsa_key" ]; then
    ssh-keygen -N "" -t rsa -f "${BASEDIR}/ssh_host_rsa_key"
fi
if [ ! -r "${BASEDIR}/ssh_host_dsa_key" ]; then
    ssh-keygen -N "" -t dsa -f "${BASEDIR}/ssh_host_dsa_key"
fi
if [ ! -r "${BASEDIR}/ssh_host_ecdsa_key" ]; then
    ssh-keygen -N "" -t ecdsa -f "${BASEDIR}/ssh_host_ecdsa_key"
fi
if [ ! -r "${BASEDIR}/ssh_host_ed25519_key" ]; then
    ssh-keygen -N "" -t ed25519 -f "${BASEDIR}/ssh_host_ed25519_key"
fi

echo "+ Replace ssh host keys"
mkdir -p "${IMG_DIR}/etc/ssh"
cat "${BASEDIR}/ssh_host_rsa_key" > "${IMG_DIR}/etc/ssh/ssh_host_rsa_key"
cat "${BASEDIR}/ssh_host_rsa_key.pub" > "${IMG_DIR}/etc/ssh/ssh_host_rsa_key.pub"
cat "${BASEDIR}/ssh_host_dsa_key" > "${IMG_DIR}/etc/ssh/ssh_host_dsa_key"
cat "${BASEDIR}/ssh_host_dsa_key.pub" > "${IMG_DIR}/etc/ssh/ssh_host_dsa_key.pub"
cat "${BASEDIR}/ssh_host_ecdsa_key" > "${IMG_DIR}/etc/ssh/ssh_host_ecdsa_key"
cat "${BASEDIR}/ssh_host_ecdsa_key.pub" > "${IMG_DIR}/etc/ssh/ssh_host_ecdsa_key.pub"
cat "${BASEDIR}/ssh_host_ed25519_key" > "${IMG_DIR}/etc/ssh/ssh_host_ed25519_key"
cat "${BASEDIR}/ssh_host_ed25519_key.pub" > "${IMG_DIR}/etc/ssh/ssh_host_ed25519_key.pub"

echo "+ Disable SSH firewall rule"
sed -i -E '/    iptables -I INPUT -j DROP -p tcp --dport 22/s/^/#/g' "${IMG_DIR}/opt/rockrobo/watchdog/rrwatchdoge.conf"
sed -i -E 's/iptables/true    /' "${IMG_DIR}/opt/rockrobo/watchdog/WatchDoge"

# Run custom scripts
custom_function

echo "+ Discard unused blocks"
fstrim "$IMG_DIR"

install -d -m 0755 "$OUTDIR"

if [ $ENABLE_DIFF -eq 1 ]; then
    echo "+ Create diff"
    mkdir -p "${IMG_DIR}.org"
    mount -o loop "${FW_DIR}/disk.img.org" ${IMG_DIR}.org
    diff -ruN "${IMG_DIR}.org" "${IMG_DIR}" 2>/dev/null | sed "s@${FW_TMPDIR}@@g" > ${OUTDIR}/${FIRMWARE_BASENAME}.diff
fi

umount_image

PIGZ="$(type -p pigz)"
if [ ! -x "$PIGZ" ]; then
    TAR_ARGS="-z"
    echo "! If you install pigz, the firmware will be created faster (e.g. by (apt|dnf|zypper) install pigz)"
else
    TAR_ARGS="-I pigz"
fi

echo "Pack new firmware"
PATCHED="${FW_DIR}/${FIRMWARE_FILENAME}_patched.pkg"
tar -C "$FW_DIR" $TAR_ARGS -cf "$PATCHED" disk.img
if [ ! -r "$PATCHED" ]; then
    echo "File $PATCHED not found! Packing the firmware was unsuccessful."
    cleanup_and_exit 1
fi

echo "Encrypt firmware"
$CCRYPT -e -K "$PASSWORD_FW" "$PATCHED"

echo "Copy firmware to ${OUTDIR}/${FIRMWARE_BASENAME} and creating checksums"
install -m 0644 "${PATCHED}.cpt" "${OUTDIR}/${FIRMWARE_BASENAME}"

md5sum "${OUTDIR}/${FIRMWARE_BASENAME}" > "${OUTDIR}/${FIRMWARE_BASENAME}.md5"
sed -i -r "s/ .*\/(.+)/  \1/g" "${OUTDIR}/${FIRMWARE_BASENAME}.md5"
chmod 0644 "${OUTDIR}/${FIRMWARE_BASENAME}.md5"

cat "${OUTDIR}/${FIRMWARE_BASENAME}.md5"
echo "FINISHED"

cleanup_and_exit
