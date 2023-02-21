SUMMARY = "Universal Boot Loader Splash Screen for HELIOS RCD Embedded Devices"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI += "\
    file://Helios_Color_White_BG_800x480px.bmp \
"

S = "${WORKDIR}"

UBOOT_SPLASH_SRC = "Helios_Color_White_BG_800x480px.bmp"
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

ALLOW_EMPTY:${PN} = "1"
FILES:${PN} = "/boot"
