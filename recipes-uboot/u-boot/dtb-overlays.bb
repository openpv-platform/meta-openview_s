SUMMARY = "Kernel device tree overlay recipe file"
LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

THISAPPENDFILESDIR := "${THISDIR}/files"

DEPENDS = "dtc-native"

S = "${WORKDIR}"

OVERLAY_DTS_FILES = " \
        5-inch-screen-overlay \
        7-inch-screen-overlay \
        10-inch-screen-overlay \
        m4-can-overlay \
        empty-overlay \
        rtc-overlay \
        "

do_compile() {
    for dts in ${OVERLAY_DTS_FILES}; do
        # Cleanup previous build artifact
        [ -f "${B}/${dts}.dtbo" ] && rm "${B}/${dts}.dtbo"
        # Compile overlay
        echo ${dts}
        dtc -O dtb -o ${B}/${dts}.dtbo ${THISAPPENDFILESDIR}/${dts}.dts
    done
}

do_install[depends] = "tf-a-stm32mp:do_deploy"

do_install() {
    install -d ${D}/boot
    install -d ${D}/boot/overlays
    install -d ${D}/boot/tf-a

    # install the 5-inch LCD overlay
    install -m 644 ${B}/5-inch-screen-overlay.dtbo ${D}/boot/overlays/5-inch-screen-overlay.dtbo

    # install the 7-inch LCD overlay
    install -m 644 ${B}/7-inch-screen-overlay.dtbo ${D}/boot/overlays/7-inch-screen-overlay.dtbo

    # install the 10-inch LCD overlay
    install -m 644 ${B}/10-inch-screen-overlay.dtbo ${D}/boot/overlays/10-inch-screen-overlay.dtbo
    
    # install the m4-can overlay and the m4-can based TF-A 
    install -m 644 ${B}/m4-can-overlay.dtbo ${D}/boot/overlays/disabled_m4-can-overlay.dtbo
    install -m 644 ${DEPLOY_DIR_IMAGE}/arm-trusted-firmware/tf-a-stm32mp157a-right_cost_display-mx-m4can.stm32 ${D}/boot/tf-a/tf-a_M4-CAN_emmc.stm32

    #install an a7-can backup in case we need to switch back to CAN A7 
    install -m 644 ${DEPLOY_DIR_IMAGE}/arm-trusted-firmware/tf-a-stm32mp157a-right_cost_display-mx-emmc.stm32 ${D}/boot/tf-a/tf-a_A7-CAN-backup_emmc.stm32

    install -m 644 ${B}/empty-overlay.dtbo ${D}/boot/overlays/empty-overlay.dtbo
    install -m 644 ${B}/rtc-overlay.dtbo ${D}/boot/overlays/rtc-overlay.dtbo
}

ALLOW_EMPTY:${PN} = "1"
FILES:${PN} = "/boot/overlays/5-inch-screen-overlay.dtbo \
               /boot/overlays/7-inch-screen-overlay.dtbo \
               /boot/overlays/10-inch-screen-overlay.dtbo \
               /boot/overlays/disabled_m4-can-overlay.dtbo \
               /boot/tf-a/tf-a_M4-CAN_emmc.stm32 \
               /boot/tf-a/tf-a_A7-CAN-backup_emmc.stm32 \
               /boot/overlays/empty-overlay.dtbo \
               /boot/overlays/rtc-overlay.dtbo \
              "
