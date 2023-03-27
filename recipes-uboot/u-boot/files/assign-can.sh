#!/bin/bash

# Simple script to update the CAN peripheral assignment

# allow TF-A write updates
echo 0 > /sys/class/block/mmcblk1boot0/force_ro

# User must pass which processer to assign CAN to
if [ "$1" == "m4" ]
then
    # unpack the static M4-CAN based TF-A binary into mmcblk1boot0
    dd if=/boot/tf-a/tf-a_M4-CAN_emmc.stm32 of=/dev/mmcblk1boot0 conv=fdatasync
    # activate the CAN M4 kernel overlay
    cp /boot/overlays/disabled_m4-can-overlay.dtbo /boot/overlays/active_m4-can-overlay.dtbo

else if [ "$1" == "a7" ]
then
    # unpack the backup A7-CAN based TF-A binary into mmcblk1boot0
    dd if=/boot/tf-a/tf-a_A7-CAN-backup_emmc.stm32 of=/dev/mmcblk1boot0 conv=fdatasync
    # remove the M4 CAN overlay that may be active
    rm /boot/overlays/active_m4-can-overlay.dtbo
else
    echo "No processor provided..." 
    exit
fi
fi

# enable mmcblk1boot0 as the TF-A boot device (default)
mmc bootpart enable 1 1 /dev/mmcblk1
sync
systemctl reboot