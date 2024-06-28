# Change the Files path for the procps directory with the one that is in our repository.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://Helios_Color_White_BG_800x480px.png \
    file://Helios_Color_White_BG_1024x600px.png \
    file://Helios_Color_White_BG_1280x800px.png \
    file://early-weston.env \
    "

# updated recipe will install a copy of the 800x480 image to a folder
# for storing in case screen changes 
do_install:append() {
    install -d ${D}${datadir}/helios_backgrounds
    install -m 0644 ${WORKDIR}/Helios_Color_White_BG_800x480px.png ${D}${datadir}/helios_backgrounds/
    install -m 0644 ${WORKDIR}/Helios_Color_White_BG_1024x600px.png ${D}${datadir}/helios_backgrounds/
    install -m 0644 ${WORKDIR}/Helios_Color_White_BG_1280x800px.png ${D}${datadir}/helios_backgrounds/

    # default background is 800x480 for now
    install -d ${D}${datadir}/psplash
    install -m 0644 ${WORKDIR}/Helios_Color_White_BG_800x480px.png ${D}${datadir}/psplash/splash.png

    # install updated weston env file:
    install -d ${D}${sysconfdir}/xdg/weston
    install -m 0644 ${WORKDIR}/early-weston.env ${D}${sysconfdir}/xdg/weston/early-weston.env
}

FILES:${PN} += "\
        ${datadir}/helios_backgrounds/Helios_Color_White_BG_800x480px.png  \
        ${datadir}/helios_backgrounds/Helios_Color_White_BG_1024x600px.png \
        ${datadir}/helios_backgrounds/Helios_Color_White_BG_1280x800px.png \
        ${datadir}/psplash/splash.png \
        ${sysconfdir}/xdg/weston/early-weston.env "

