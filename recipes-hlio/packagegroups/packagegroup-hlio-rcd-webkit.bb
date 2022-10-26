SUMMARY = "Packagegroup to encapsulate webkit dependencies"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = "\
            packagegroup-hlio-rcd-webkit \
            "

RDEPENDS:packagegroup-hlio-rcd-webkit += " \
        qtbase-plugins \
        wpewebkit-qtwpe-qml-plugin \
        qt-wpe-simple-browser \
        eglfs-configs \
        "
