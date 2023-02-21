#
# This file was derived from the 'Hello World!' example recipe in the
# Yocto Project Development Manual.
#
SUMMARY = "Type c role switch binary"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

# PROVIDES += "libtype-c-role-switch.so"
# RPROVIDES:${PN} += "libtype-c-role-switch.so"

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

FILES:${PN} = "${includedir}/type-c-role-switch.h ${libdir}/*.so.* ${libdir}/*.so"
