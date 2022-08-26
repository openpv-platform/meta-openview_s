FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
        file://0001-Clean-up-defconfig.patch \
        file://0002-Support-multiple-memory-sizes-with-single-device-tre.patch \
        "
