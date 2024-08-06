SUMMARY = "Components specific to ota application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-hlio-ota \
            packagegroup-hlio-ota-tools \
            packagegroup-hlio-ota-graphics \
            "

RDEPENDS:packagegroup-hlio-ota = "\
    packagegroup-hlio-ota-tools \
    packagegroup-hlio-ota-graphics \
    "

SUMMARY:packagegroup-hlio-ota-tools = "Custom tools for RCD OTA application."
RDEPENDS:packagegroup-hlio-ota-tools = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'usbgadget', 'usbotg-gadget-config', '', d)} \
    \
    lcd-config \
    uvlo \
    util-linux \
    fw-env-config \
    "

SUMMARY:packagegroup-hlio-ota-graphics = "Graphics layers for RCD OTA application."
RDEPENDS:packagegroup-hlio-ota-graphics = "\
    kmscube \
    boot-display-app \
    evtest \
    "
