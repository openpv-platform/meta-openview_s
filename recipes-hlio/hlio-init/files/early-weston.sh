#!/bin/bash
# Weston minimal early init script. 
#
# Description: 
#  Loads all dependencies necessary to launch weston, then CAN, then touch as fast as possible. 
#
#  Set WESTON_APP_TO_RUN in early-weston.env for the app to run on early init
#
#  Also must work in conjunction with values located in /etc/xdg/weston/weston.ini
#
# Author: Jonathan Kaufmann
# Date: 11/29/2022
#

source /etc/xdg/weston/early-weston.env

# Load GPU
modprobe galcore

# TODO: This is really only necessary for touch and is pretty heavy and seems to add about 80ms.
# TODO: consider manually enabling the event/input0 or whatever necessary for weston
udevd &
UDEV=$!

# Prep all needed weston mount points
mount -t proc none /proc
mount -t sysfs none /sys
mount -t tmpfs -o size=47404k,rw,nosuid,nodev,relatime,size=47404k,mode=700,uid=1000,gid=1000 tmpfs /tmp

mkdir -p /dev/pts
mount -t devpts -o mode=0620,gid=5 devpts /dev/pts

# Required for Xwayland
mkdir -p /tmp/.X11-unix
chgrp video /tmp/.X11-unix
chmod 770 /tmp/.X11-unix

mkdir -p ${XDG_RUNTIME_DIR}
chmod 0700 ${XDG_RUNTIME_DIR}

ARGS="--backend=drm-backend.so"
ARGS="$ARGS --current-mode"
ARGS="$ARGS --config=/etc/xdg/weston/weston.ini"
ARGS="$ARGS --drm-device=card0"
ARGS="$ARGS --continue-without-input"
ARGS="$ARGS --flight-rec-scopes="
ARGS="$ARGS --logger-scopes="

# Run weston - doing the non "launch" mode as root is about 200ms faster for some reason
/usr/bin/weston --tty=7 $ARGS &
#/usr/bin/weston-launch --tty=/dev/tty7 --user="${WESTON_USER}" -- ${ARGS} &

# Bring up localhost
ifconfig lo up

# Setup CAN modules if either CANx_BITRATE is set
modprobe -a can_dev m_can m_can_platform can can_raw

# Load the i2c for touch driver after UI is up
modprobe i2c_stm32f7_drv

# Initialize CAN while waiting touch
# [ -n "$CAN0_BITRATE" ] && ip link set can0 up type can bitrate $CAN0_BITRATE &> /dev/null
# [ -n "$CAN1_BITRATE" ] && ip link set can1 up type can bitrate $CAN1_BITRATE &> /dev/null

# Wait for udev to load touch
END_TIME=$((SECONDS+2))
while [ ! -e /dev/input/event0 ]; do
    if [ $SECONDS -gt $END_TIME ]; then    # allow an exit after 2 seconds
        echo "Timed out waiting for touch screen input device"
        break;
    fi
    sleep 0.05;
done

sleep 0.05
kill -TERM $UDEV
