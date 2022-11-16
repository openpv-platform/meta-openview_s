SUMMARY = "Kernel device tree overlay recipe file"
LICENSE = "CLOSED"

SRC_URI += "\
    file://disabled_7-inch-screen-overlay.dtbo \
"

S = "${WORKDIR}"


inherit deploy

do_compile[noexec] = "1"

#TODO: Add custom recipe to compile overlays if they change
do_install() {
    install -d ${D}/boot
    install -d ${D}/boot/overlays

    install -m 644 ${S}/disabled_7-inch-screen-overlay.dtbo ${D}/boot/overlays/disabled_7-inch-screen-overlay.dtbo

}

ALLOW_EMPTY:${PN} = "1"
FILES:${PN} = "/boot/"
