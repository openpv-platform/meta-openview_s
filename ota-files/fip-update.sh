#!/bin/sh -

# Copy this script along with updated fip image to same location
# fip image filename should be 'fip-update.bin'

echo Pulling original fip binary from primary partition
/bin/dd if=/dev/mmcblk1p3 of=./fip-original.bin ibs=1024 count=4096

echo Writing original fip binary into secondary partition
/bin/dd of=/dev/mmcblk1p4 if=./fip-original.bin

if [[ -f ./fip-update.bin ]]; then
    echo Writing new fip binary into primary partition
    /bin/dd of=/dev/mmcblk1p3 if=./fip-update.bin
else
    echo Missing new fip binary, operation cancelled.
fi
