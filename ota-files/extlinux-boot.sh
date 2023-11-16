#!/usr/bin/env bash

# Script to run on display to modify extlinux.conf to boot to flash image or ota image
# Expects to be run from /boot and for the source config files to be present
usage="Usage: $0 [flash|ota]"

MY_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# echo "$MY_PATH"

case "$1" in
    f*)
        if [ -f "$MY_PATH/extlinux.conf.flash" ]; then
            cp "$MY_PATH/extlinux.conf.flash" "$MY_PATH/extlinux/extlinux.conf"
            echo "flash extlinux copied and ready for reboot"
        else
            echo "No flash extlinux copy present in $MY_PATH, no action taken."
        fi
        ;;
    o*)
        if [ ! -f "$MY_PATH/extlinux.conf.flash" ]; then
            echo "Backing up original extlinux.conf as $MY_PATH/extlinux.conf.flash"
            cp "$MY_PATH/extlinux/extlinux.conf" "$MY_PATH/extlinux.conf.flash"
        fi
        if [ -f "$MY_PATH/extlinux.conf.ota" ]; then
            cp "$MY_PATH//extlinux.conf.ota" "$MY_PATH/extlinux/extlinux.conf"
            echo "ota extlinux copied and ready for reboot"
        fi
        ;;
    *)
        echo $usage
        exit 1
        ;;
esac

