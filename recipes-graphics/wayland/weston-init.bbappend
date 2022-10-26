# Change the Files path for the procps directory with the one that is in our repository.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://Helios_Color_White_BG_800x480px.png \
            "

do_install:append() {
    install -d ${D}${datadir}/weston/backgrounds

    install -m 0644 ${WORKDIR}/Helios_Color_White_BG_800x480px.png ${D}${datadir}/weston/backgrounds/Helios_Color_White_BG_800x480px.png
}
