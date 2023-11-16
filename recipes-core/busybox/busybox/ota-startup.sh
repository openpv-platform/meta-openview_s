#!/bin/sh

echo "Openview OTA Startup"

echo Configure LCD pins
/sbin/lcd-pin-config

echo Load the Under Voltage Lockout Kernel Module
modprobe uvlo

echo Load the galcore driver
modprobe galcore

# Mount config directory for configuring usb-otg i/f
echo "Mounting config filesystem"
mount -t configfs none /sys/kernel/config

# Configure usb-otg
echo "Configuring usb-otg"
/sbin/stm32_usbotg_eth_config.sh start

# Configure the ndis port address
echo "Configuring ndis port address to 192.168.7.1"
/sbin/ifconfig usb0 192.168.7.1 netmask 255.255.255.0

# Start udhcpd
echo "Start udhcpd"
/usr/sbin/udhcpd /etc/udhcpd.conf

# Start dropbear
echo "Start dropbear ssh server"
/etc/init.d/dropbear start

# Start i2c driver and evdev (udev) for touch
modprobe evdev
modprobe i2c_stm32f7_drv
