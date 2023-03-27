SUMMARY = "Kernel device tree overlay recipe file"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI += "\
    file://disabled_7-inch-screen-overlay.dtbo \
    file://disabled_m4-can-overlay.dtbo \
    file://tf-a_A7-CAN-backup_emmc.stm32 \
    file://tf-a_M4-CAN_emmc.stm32 \
    file://assign-can.sh \
"

RDEPENDS:dtb-overlays = "bash"

S = "${WORKDIR}"


# TODO: make process for overlays not worked out yet.
# do_compile() {
#     # bbnote "EXTRA_OEMAKE=${EXTRA_OEMAKE}"
#     oe_runmake clean
#     oe_runmake all
# }

do_install() {
    install -d ${D}/boot
    install -d ${D}/boot/overlays
    install -d ${D}/boot/tf-a
    install -d ${D}${base_sbindir}

    # install the 7-inch LCD overlay
    install -m 644 ${S}/disabled_7-inch-screen-overlay.dtbo ${D}/boot/overlays/disabled_7-inch-screen-overlay.dtbo
    
    # install the m4-can overlay and the m4-can based TF-A 
    install -m 644 ${S}/disabled_m4-can-overlay.dtbo ${D}/boot/overlays/disabled_m4-can-overlay.dtbo
    install -m 644 ${S}/tf-a_M4-CAN_emmc.stm32 ${D}/boot/tf-a/tf-a_M4-CAN_emmc.stm32

    #install an a7-can backup in case we need to switch back to CAN A7
    install -m 644 ${S}/tf-a_A7-CAN-backup_emmc.stm32 ${D}/boot/tf-a/tf-a_A7-CAN-backup_emmc.stm32

    # install helper function to allow switching CAN peripheral from A7->M4 and vice versa
    install -m 755 ${S}/assign-can.sh ${D}${base_sbindir}/assign-can.sh
}

ALLOW_EMPTY:${PN} = "1"
FILES:${PN} = "/boot/overlays/disabled_7-inch-screen-overlay.dtbo \
               /boot/overlays/disabled_m4-can-overlay.dtbo \
               /boot/tf-a/tf-a_M4-CAN_emmc.stm32 \
               /boot/tf-a/tf-a_A7-CAN-backup_emmc.stm32 \
               ${base_sbindir}/assign-can.sh "
