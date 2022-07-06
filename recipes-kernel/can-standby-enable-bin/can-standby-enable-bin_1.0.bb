#
# This file was derived from the 'Hello World!' example recipe in the
# Yocto Project Development Manual.
#
SUMMARY = "Type c role switch binary"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://Makefile \
    file://can-standby-enable-lib.c \
    file://can-standby-enable-lib.h \
    file://can-standby-enable-bin.c \
    "

S = "${WORKDIR}"

DEPENDS = " libgpiod "

do_compile() {
    oe_runmake
}
do_install() {
    install -d ${D}${bindir}
    install -m 0755 can-standby-enable-bin ${D}${bindir}
}

FILES_${PN} = "${bindir}/*"
