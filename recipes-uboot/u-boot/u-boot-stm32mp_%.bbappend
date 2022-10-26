FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
        file://0001-Clean-up-u-boot-defconfig.patch \
        file://0002-Support-multiple-dram-sizes-with-single-device-tree.patch \
        "
