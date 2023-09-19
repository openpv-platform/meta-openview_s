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

# Run CAN Coprocessor First if Available.
if [ -f /usr/local/Ahsoka/start_can_helper.sh ];
then
   /usr/local/Ahsoka/start_can_helper.sh &
fi

ARGS="--backend=drm-backend.so"
ARGS="$ARGS --current-mode"
ARGS="$ARGS --config=/etc/xdg/weston/weston.ini"
ARGS="$ARGS --drm-device=card0"
ARGS="$ARGS --continue-without-input"
ARGS="$ARGS --flight-rec-scopes="
ARGS="$ARGS --logger-scopes="

# Run weston - doing the non "launch" mode as root is about 200ms faster for some reason
/usr/bin/weston --tty=7 $ARGS &

# Bring up localhost
ifconfig lo up

# Setup CAN modules if either CANx_BITRATE is set
if [ ! -f /usr/local/Ahsoka/start_can_helper.sh ];
then
	modprobe -a can_dev m_can m_can_platform can can_raw
fi
