SUMMARY = "Universal Boot Loader Splash Screen for HELIOS RCD Embedded Devices"
LICENSE = "CLOSED"


SRC_URI += "\
    file://hlio-logo.bmp \
"

S = "${WORKDIR}"

UBOOT_SPLASH_SRC = "hlio-logo.bmp"
UBOOT_SPLASH_IMAGE ?= "splash"

inherit deploy

do_compile[noexec] = "1"

# do install process mimicks the same install process provided by st
do_install() {
    install -d ${D}/boot
    if [ -e "${S}/${UBOOT_SPLASH_SRC}" ]; then
        install -m 644 ${S}/${UBOOT_SPLASH_SRC} ${D}/boot/${UBOOT_SPLASH_IMAGE}.bmp
    fi
}

ALLOW_EMPTY_${PN} = "1"
FILES_${PN} = "/boot"
