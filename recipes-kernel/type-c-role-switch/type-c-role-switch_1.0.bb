#
# This file was derived from the 'Hello World!' example recipe in the
# Yocto Project Development Manual.
#
SUMMARY = "Type c role switch binary"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# PROVIDES += "libtype-c-role-switch.so"
# RPROVIDES_${PN} += "libtype-c-role-switch.so"

SRC_URI = " \
    file://Makefile \
    file://type-c-role-switch.h \
    file://type-c-role-switch.c \
    "

S = "${WORKDIR}"

inherit native

do_compile() {
    oe_runmake clean
    oe_runmake libtype-c-role-switch.so
}
do_install() {
    install -d ${D}${includedir}
    install -m 0644 type-c-role-switch.h ${D}${includedir}/type-c-role-switch.h
    install -d ${D}${libdir}
    install -m 0755 libtype-c-role-switch.so ${D}${libdir}/libtype-c-role-switch.so.1.0
    ln -sf libtype-c-role-switch.so.1.0 ${D}${libdir}/libtype-c-role-switch.so
}

FILES_${PN} = "${includedir}/type-c-role-switch.h ${libdir}/*.so.* ${libdir}/*.so"
