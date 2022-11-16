SUMMARY = "7 inch high res modifications recipe file"
LICENSE = "CLOSED"

SRC_URI += "\
    file://Makefile \
    file://lcd-pin-config.c \
    file://lcd-config \
"

RDEPENDS:lcd-config = "bash"

S = "${WORKDIR}"

do_compile() {
    # bbnote "EXTRA_OEMAKE=${EXTRA_OEMAKE}"
    oe_runmake clean
    oe_runmake lcd-pin-config
}

do_install() {    
    install -d ${D}${bindir}
    install -m 755 lcd-pin-config ${D}${bindir}
    install -m 755 lcd-config ${D}${bindir}
}

FILES:${PN} += "${bindir}/lcd-pin-config ${bindir}/lcd-config"
