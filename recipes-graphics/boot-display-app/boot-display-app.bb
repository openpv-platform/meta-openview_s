LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

# No information for SRC_URI yet (only an external source tree was specified)
SRC_URI += "file://Cairo/"
SRC_URI += "file://DRM/"
SRC_URI += "file://BootDisplayApp/"
SRC_URI += "file://Touch/"
SRC_URI += "file://CMakeLists.txt"


S="${WORKDIR}"

DEPENDS += "cairo virtual/libgles2 virtual/egl libdrm"
RDEPENDS:${PN} = "cairo libdrm"

inherit cmake pkgconfig

# Specify any options you want to pass to cmake using EXTRA_OECMAKE:
EXTRA_OECMAKE = ""

TARGET_CC_ARCH += "${LDFLAGS}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/Install/BootDisplayApp ${D}${bindir}/BootDisplayApp
}

FILES:${PN} += "${bindir}"
