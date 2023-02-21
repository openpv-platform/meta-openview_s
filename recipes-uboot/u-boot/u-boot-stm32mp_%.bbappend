FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
        file://0001-Clean-up-u-boot-defconfig.patch \
        file://0002-Support-multiple-dram-sizes-with-single-device-tree.patch \
        file://0003-fdt-overlay-configs.patch \
        file://0004-fdt-overlay-comments.patch \
        file://0005-boot-cmd-strip-down.patch \
        file://0006-defconfig-optimizations.patch \
        file://0007-disable-console.patch \
        "
