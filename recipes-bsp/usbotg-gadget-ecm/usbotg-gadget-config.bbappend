# Copyright (C) 2018, STMicroelectronics - All Rights Reserved
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Add usbotg ncm-ecm support to the USB gadget by modifying meta-st-openstlinux recipe."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "1.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/usbotg-gadget-config/:"

SRC_URI:append = " \
    file://stm32_usbotg_eth_config.sh \
    file://53-usb-otg-ecm.network \
    "

S = "${WORKDIR}/git"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_unitdir}/network
        install -m 0644 ${WORKDIR}/53-usb-otg-ecm.network ${D}${systemd_unitdir}/network
    fi

    install -d ${D}${base_sbindir}
    install -m 0755 ${WORKDIR}/stm32_usbotg_eth_config.sh ${D}${base_sbindir}
}
