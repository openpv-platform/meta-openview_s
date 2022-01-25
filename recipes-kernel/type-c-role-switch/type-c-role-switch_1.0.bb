DESCRIPTION = "A basic tool to switch the role of the usb c"
LICENSE = "CLOSED"

SRC_URI = " \
           file://type-c-role-switch.sh \
           "

do_install() {
    install -d ${D}${base_bindir}
    install -m 0755 ${WORKDIR}/type-c-role-switch.sh ${D}${base_bindir}
}

FILES_${PN} += "${base_bindir}/type-c-role-switch.sh"
