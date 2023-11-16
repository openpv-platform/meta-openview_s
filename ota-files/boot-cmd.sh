#!/bin/sh -

usage="Usage: $0 [flash|ota]"

# bootcmd=""

case "$1" in
    f*)
        bootcmd="if test \${boot_device} = usb;then stm32prog \${boot_device} \${boot_instance}; fi;sysboot mmc 1:6 any \${scriptaddr} /extlinux/extlinux.conf"
        ;;
    o*)
        bootcmd="ext4load mmc 1:6 \${kernel_addr_r} uImage-ota; ext4load mmc 1:6 \${ramdisk_addr_r} uRamdisk; ext4load mmc 1:6 \${fdt_addr_r} stm32mp157a-right_cost_display-mx.dtb; bootm \${kernel_addr_r} \${ramdisk_addr_r} \${fdt_addr_r}"
        ;;
    *)
        echo $usage
        exit 1
        ;;
esac

fw_setenv bootcmd_stm32mp "$bootcmd"
fw_printenv bootcmd_stm32mp
