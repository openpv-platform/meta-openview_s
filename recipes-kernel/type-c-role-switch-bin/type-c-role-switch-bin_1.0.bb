#
# This file was derived from the 'Hello World!' example recipe in the
# Yocto Project Development Manual.
#
SUMMARY = "Type c role switch binary"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

# RDEPENDS:${PN} += " type-c-role-switch "

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

FILES:${PN} = "${bindir}/*"
