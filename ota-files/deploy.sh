#!/bin/bash -
# Script to copy build artifcacts and support scripts to OpenView display

# Assumes built files are in ./deploy and display is available @ 192.168.7.1
targetIP="192.168.7.1"
scpTarget="root@$targetIP"

# Auto-remove and re-add this address to known hosts
ssh-keygen -R "$targetIP"
ssh -o StrictHostKeyChecking=no "$scpTarget" -t "cd ~"

# Deploy directory holds the ramdisk and Linux Kernel binaries
scp deploy/* "$scpTarget:/boot/"

# Needed for u-boot environment and boot-cmd method only
scp uboot-env-original "$scpTarget:/etc/u-boot-initial-env"
scp ../recipes-uboot/u-boot/files/fw_env.config "$scpTarget:/etc/"
scp boot-cmd.sh "$scpTarget:/boot"

# Needed for the extlinux.conf method only 
scp extlinux-boot.sh extlinux.conf.ota "$scpTarget:/boot"
