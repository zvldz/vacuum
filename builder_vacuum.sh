#!/bin/bash
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

function cleanup_and_exit() {
    if [ "$1" = 0 -o -z "$1" ]; then
        exit 0
    else
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
    echo "Usage: sudo $(basename $0) --firmware=v11_003194.pkg [--unpack-and-mount|--run-custom-script=SCRIPT|--help]"
    custom_print_usage
}

function print_help() {
    cat << EOF

Options:
  -h, --help                 Prints this message
  -f, --firmware=PATH        Path to firmware file
  --unpack-and-mount         Only unpack and mount image
  --run-custom-script=SCRIPT Run custom script (if 'ALL' run all scripts from custom-script)

Each parameter that takes a file as an argument accepts path in any form

Report bugs to: https://github.com/zvldz/vacuum/issues
Original Author: Dennis Giese [dgiese@dontvacuum.me], https://github.com/dgiese/dustcloud
EOF
    custom_print_help
}

fixed_cmd_subst() {
    eval '
    '"$1"'=$('"$2"'; ret=$?; echo .; exit "$ret")
    set -- "$1" "$?"
    '"$1"'=${'"$1"'%??}
    '
    return "$2"
}

readlink_f() (
    link=$1 max_iterations=40
    while [ "$max_iterations" -gt 0 ]; do
        max_iterations=$(($max_iterations - 1))
        fixed_cmd_subst dir 'dirname -- "$link"' || exit
        fixed_cmd_subst base 'basename -- "$link"' || exit
        cd -P -- "$dir" || exit
        link=${PWD%/}/$base
        if [ ! -L "$link" ]; then
            printf '%s\n' "$link"
            exit
        fi
        fixed_cmd_subst link 'ls -ld -- "$link"' || exit
        link=${link#* -> }
    done
    printf >&2 'Loop detected\n'
    exit 1
)

UNPACK_AND_MOUNT=0
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
        *-run-custom-script)
            CUSTOM_SCRIPT="$ARG"
            if [ "$CUSTOM_SCRIPT" = "ALL" ]; then
                for FILE in ./custom-script/*.sh; do
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
            print_usage
            cleanup_and_exit 1
            ;;
    esac
done

SCRIPT="$0"
SCRIPTDIR=$(dirname "${0}")
COUNT=0

while [ -L "${SCRIPT}" ]
do
    SCRIPT=$(readlink_f ${SCRIPT})
    COUNT=$(expr ${COUNT} + 1)
    if [ ${COUNT} -gt 100 ]
    then
        echo "Too many symbolic links"
        cleanup_and_exit 1
    fi
done
BASEDIR=$(dirname "${SCRIPT}")
echo "Script path: $BASEDIR"

if [ $EUID -ne 0 ]; then
    echo "You need root privileges to execute this script"
    cleanup_and_exit 1
fi

IS_MAC=false
if [[ $OSTYPE == darwin* ]]; then
    # Mac OSX
    IS_MAC=true
    echo "Running on a Mac, adjusting commands accordingly"
fi

CCRYPT="$(type -p ccrypt)"
if [ ! -x "$CCRYPT" ]; then
    echo "ccrypt not found! Please install it (e.g. by (apt|brew|dnf|zypper) install ccrypt)"
    cleanup_and_exit 1
fi

PASSWORD_FW="rockrobo"

if [ ! -r "$FIRMWARE_PATH" ]; then
    echo "You need to specify an existing firmware file, e.g. v11_003194.pkg"
    cleanup_and_exit 1
fi

FIRMWARE_PATH=$(readlink_f "$FIRMWARE_PATH")
FIRMWARE_BASENAME=$(basename $FIRMWARE_PATH)
FIRMWARE_FILENAME="${FIRMWARE_BASENAME%.*}"

# Generate SSH Host Keys
echo "Generate SSH Host Keys if necessary"

if [ ! -r ssh_host_rsa_key ]; then
    ssh-keygen -N "" -t rsa -f ssh_host_rsa_key
fi
if [ ! -r ssh_host_dsa_key ]; then
    ssh-keygen -N "" -t dsa -f ssh_host_dsa_key
fi
if [ ! -r ssh_host_ecdsa_key ]; then
    ssh-keygen -N "" -t ecdsa -f ssh_host_ecdsa_key
fi
if [ ! -r ssh_host_ed25519_key ]; then
    ssh-keygen -N "" -t ed25519 -f ssh_host_ed25519_key
fi

FW_TMPDIR="$(pwd)/$(mktemp -d fw.XXXXXX)"

echo "Decrypt firmware"
FW_DIR="$FW_TMPDIR/fw"
mkdir -p "$FW_DIR"
cp "$FIRMWARE_PATH" "$FW_DIR/$FIRMWARE_FILENAME"
$CCRYPT -d -K "$PASSWORD_FW" "$FW_DIR/$FIRMWARE_FILENAME"

echo "Unpack firmware"
pushd "$FW_DIR"
tar -xzf "$FIRMWARE_FILENAME"
if [ ! -r disk.img ]; then
    echo "File disk.img not found! Decryption and unpacking was apparently unsuccessful."
    cleanup_and_exit 1
fi
popd

IMG_DIR="$FW_TMPDIR/image"
mkdir -p "$IMG_DIR"

if [ "$IS_MAC" = true ]; then
    FUSE-EXT2="$(type -p fuse-ext2)"
    if [ ! -x "$FUSE-EXT2" ]; then
        echo "fuse-ext not found! Please install it from https://github.com/alperakcan/fuse-ext2"
        cleanup_and_exit 1
    fi
    $FUSE-EXT2 -ext2 "$FW_DIR/disk.img" "$IMG_DIR" -o rw+
else
    mount -o loop "$FW_DIR/disk.img" "$IMG_DIR"
fi

if [ $UNPACK_AND_MOUNT -eq 1 ]; then
    echo "Image mounted to $IMG_DIR"
    echo "Run 'umount $IMG_DIR' for unmount the image"
    cleanup_and_exit
fi

echo "Replace ssh host keys"
cat ssh_host_rsa_key > $IMG_DIR/etc/ssh/ssh_host_rsa_key
cat ssh_host_rsa_key.pub > $IMG_DIR/etc/ssh/ssh_host_rsa_key.pub
cat ssh_host_dsa_key > $IMG_DIR/etc/ssh/ssh_host_dsa_key
cat ssh_host_dsa_key.pub > $IMG_DIR/etc/ssh/ssh_host_dsa_key.pub
cat ssh_host_ecdsa_key > $IMG_DIR/etc/ssh/ssh_host_ecdsa_key
cat ssh_host_ecdsa_key.pub > $IMG_DIR/etc/ssh/ssh_host_ecdsa_key.pub
cat ssh_host_ed25519_key > $IMG_DIR/etc/ssh/ssh_host_ed25519_key
cat ssh_host_ed25519_key.pub > $IMG_DIR/etc/ssh/ssh_host_ed25519_key.pub

echo "Disable SSH firewall rule"
sed -i -E '/    iptables -I INPUT -j DROP -p tcp --dport 22/s/^/#/g' $IMG_DIR/opt/rockrobo/watchdog/rrwatchdoge.conf

# Run custom scripts
custom_function

echo "Discard unused blocks"
type -p fstrim > /dev/null 2>&1 && fstrim $IMG_DIR

while [ $(umount $IMG_DIR; echo $?) -ne 0 ]; do
    echo "waiting for unmount..."
    sleep 2
done

echo "Pack new firmware"
pushd $FW_DIR
PATCHED="${FIRMWARE_FILENAME}_patched.pkg"
type -p pigz > /dev/null 2>&1 && tar -I pigz -cf "$PATCHED" disk.img || tar -czf "$PATCHED" disk.img
if [ ! -r "$PATCHED" ]; then
    echo "File $PATCHED not found! Packing the firmware was unsuccessful."
    cleanup_and_exit 1
fi

echo "Encrypt firmware"
$CCRYPT -e -K "$PASSWORD_FW" "$PATCHED"
popd

echo "Copy firmware to output/${FIRMWARE_BASENAME} and creating checksums"
install -d -m 0755 output
install -m 0644 "$FW_DIR/${PATCHED}.cpt" "output/${FIRMWARE_BASENAME}"

if [ "$IS_MAC" = true ]; then
    md5 "output/${FIRMWARE_BASENAME}" > "output/${FIRMWARE_BASENAME}.md5"
else
    md5sum "output/${FIRMWARE_BASENAME}" > "output/${FIRMWARE_BASENAME}.md5"
fi
sed -i -r "s/ .*\/(.+)/  \1/g" output/${FIRMWARE_BASENAME}.md5
chmod 0644 "output/${FIRMWARE_BASENAME}.md5"

echo "Cleaning up"
rm -rf $FW_TMPDIR

echo "FINISHED"
cat "output/${FIRMWARE_BASENAME}.md5"

cleanup_and_exit
