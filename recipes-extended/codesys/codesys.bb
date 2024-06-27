SUMMARY = "Codesys Control"
DESCRIPTION = "Codesys Control Runtime for Enovation Controls"
LICENSE="CLOSED"

SRCREV = "c6d9a88f3dfdf7b380a1aeec343ebd2484f1cd57"
SRC_URI = "gitsm://git@vs-ssh.visualstudio.com/v3/Enovation/OpenView/CODESYS.OpenView_S;protocol=ssh;branch=3.5.19.0"

inherit systemd

SYSTEMD_AUTO_ENABLE = "disable"
SYSTEMD_SERVICE:${PN} += "codesyscontrol.service"

S = "${WORKDIR}/git"

SOLIBS = ".so"
FILES_SOLIBSDEV = ""
BINARIES = "Linux/Bin"
CONFIG = "Configuration"

do_compile() {
    oe_runmake -C ${S}/Platforms/Linux/Bin
}

do_install() {
    install -d ${D}${bindir}/${PN}
    install -m 0755 ${S}/Platforms/${BINARIES}/codesyscontrol  ${D}${bindir}/${PN}
    install -m 0644 ${S}/Platforms/${BINARIES}/CODESYSControl.cfg  ${D}${bindir}/${PN}
    install -m 0644 ${S}/Platforms/${BINARIES}/CODESYSControl.5in.cfg  ${D}${bindir}/${PN}
    install -m 0755 ${S}/${CONFIG}/prestart.sh ${D}${bindir}/${PN}
    install -m 0755 ${S}/Platforms/Linux/Templates/rts_set_baud/ip/rts_set_baud.sh  ${D}${bindir}/${PN}
    install -m 0644 ${S}/${CONFIG}/3S.dat   ${D}${bindir}/${PN}
	
	install -d ${D}${sysconfdir}
    install -m 0644 ${S}/${CONFIG}/cdsenvironment   ${D}${sysconfdir}
    
	install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/${CONFIG}/codesyscontrol.service ${D}${systemd_system_unitdir}/codesyscontrol.service
}

FILES:${PN} += "${systemd_system_unitdir}/codesyscontrol.service ${bindir}/${PN} ${sysconfdir}/cdsenvironment"

DEPENDS = "qtbase qtquickcontrols2 libgpiod"