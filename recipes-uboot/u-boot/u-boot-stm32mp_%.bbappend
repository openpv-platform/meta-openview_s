THISAPPENDFILESDIR := "${THISDIR}/${PN}"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
        file://0001-Clean-up-u-boot-defconfig.patch \
        file://0002-Support-multiple-dram-sizes-with-single-device-tree.patch \
        file://0003-fdt-overlay-configs.patch \
        file://0004-fdt-overlay-comments.patch \
        file://0005-boot-cmd-strip-down.patch \
        file://0006-defconfig-optimizations.patch \
        file://0007-disable-console.patch \
        file://0008-Fix-mmc_switch-excessive-timeout.patch \
        "

do_add_platform_dtsi() {
   # We are using a dummy LCD device tree include file since we do not use the LCD in u-boot
   echo 'cp -f "${THISAPPENDFILESDIR}/rcd-lcd.dtsi" "${DEVSHELL_STARTDIR}/arch/arm/boot/dts"'
   cp -f "${THISAPPENDFILESDIR}/rcd-lcd.dtsi" \
           "${DEVSHELL_STARTDIR}/arch/arm/dts/rcd-lcd.dtsi";
}

addtask add_platform_dtsi before do_configure after do_patch 
