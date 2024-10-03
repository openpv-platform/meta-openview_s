SUMMARY = "Recipe file to enable the RTC on displays which discover the device"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI += "\
    file://rtc-config \
"

RDEPENDS:rtc-config = "bash"

S = "${WORKDIR}"

do_install() {    
    install -d ${D}${base_sbindir}
    install -m 755 rtc-config ${D}${base_sbindir}/rtc-config
}

FILES:${PN} += "${base_sbindir}/rtc-config"
