THISAPPENDFILESDIR := "${THISDIR}/${PN}"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:ota = " \
                file://add-fold.cfg \
                file://ota-startup.sh \
                file://udhcpd.conf \
                "

do_install:append:ota () {
    install -m 644 ${WORKDIR}/udhcpd.conf ${D}${sysconfdir}/udhcpd.conf
    install -m 755 ${WORKDIR}/ota-startup.sh ${D}${sysconfdir}/init.d/ota-startup.sh
    update-rc.d -r ${D} ota-startup.sh start 50 2 3 4 5 .
}
