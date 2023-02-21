#!/bin/sh
set -e

# Make sure that on startup we set up the CAN transceivers to not be in standby
can-standby-enable-bin false

# Load the Under Voltage Lockout Kernel Module
modprobe uvlo

exit