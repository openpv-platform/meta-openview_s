SUMMARY = "Components for esp-hosted"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "\
            packagegroup-hlio-esp \
            "

RDEPENDS_packagegroup-hlio-esp = "\
    esp-hosted \
    "
