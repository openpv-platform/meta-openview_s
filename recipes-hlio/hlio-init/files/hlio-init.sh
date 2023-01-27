#!/bin/bash

# This is our custom init script that is passed to the kernel
# through the kernel command line arguments found in
# /boot/extlinux/extlinux.conf 
# It's main goal is to configure the display and start the
# weston framework. It then hands over control to SystemD


# orient the L/R U/D pins to correct state
/sbin/lcd-pin-config

# bring up weston and let it handle the splash screen
/sbin/early-weston.sh

# start systemd
exec /sbin/init

exit