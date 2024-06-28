DEPENDS += "freerdp"

EXTRA_OEMESON:append = " -Dbackend-rdp=true"
EXTRA_OEMESON:append = " -Dscreenshare=true"

PACKAGECONFIG:append = " rdp"
EXTRA_OECONF:append = " --enable-rdp-compositor"
EXTRA_OECONF:append = " --enable-screen-sharing"
PACKAGECONFIG:append = " systemd"

SYSTEMD_SERVICE:${PN} = "weston.service"