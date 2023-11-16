LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

# No information for SRC_URI yet (only an external source tree was specified)
SRC_URI += "file://Cairo/"
SRC_URI += "file://drm-gbm/"
SRC_URI += "file://Tests/"
SRC_URI += "file://Touch/"
SRC_URI += "file://cairo-gles-drm.c file://cairo-gles-drm.h"
SRC_URI += "file://CMakeLists.txt"

S="${WORKDIR}"

DEPENDS += "cairo virtual/libgles2 virtual/egl libdrm"
RDEPENDS:${PN} = "cairo libdrm"

inherit cmake pkgconfig

# Specify any options you want to pass to cmake using EXTRA_OECMAKE:
EXTRA_OECMAKE = ""

TARGET_CC_ARCH += "${LDFLAGS}"

do_install() {
	install -d ${D}${libdir}
	install -m 0755 ${B}/Install/${BPN}.so ${D}${libdir}/${BPN}.so
    install -d ${D}${bindir}
    install -m 0755 ${B}/CairoLibTests ${D}${bindir}/CairoLibTests
    install -d ${D}${datadir}/${BPN}
    install -m 0644 ${S}/Tests/Cloud.png ${D}${datadir}/${BPN}/Cloud.png
}

FILES:${PN} += "${bindir} ${libdir}"
