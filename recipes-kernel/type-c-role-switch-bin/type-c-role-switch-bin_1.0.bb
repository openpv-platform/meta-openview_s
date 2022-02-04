#
# This file was derived from the 'Hello World!' example recipe in the
# Yocto Project Development Manual.
#
SUMMARY = "Type c role switch binary"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# RDEPENDS_${PN} += " type-c-role-switch "

SRC_URI = " \
    file://Makefile \
    file://type-c-role-switch.c \
    file://type-c-role-switch.h \
    file://type-c-role-switch-bin.c \
    "

S = "${WORKDIR}"

do_compile() {
    oe_runmake clean
    oe_runmake
}
do_install() {
    install -d ${D}${bindir}
    install -m 0755 type-c-role-switch-bin ${D}${bindir}
}

FILES_${PN} = "${bindir}/*"
