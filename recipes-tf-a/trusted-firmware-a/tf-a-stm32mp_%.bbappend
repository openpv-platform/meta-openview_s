FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Support-multiple-dram-sizes-with-single-device-tree.patch"

do_compile:append() {
    # The following are hard coded values and this may break if modified elsewhere.
    dtsBase="stm32mp157a-right_cost_display-mx"
    config="m4can"
    soc_suffix="-stm32mp15"
    tfa_basename="tf-a"
    extra_opt="STM32MP_EMMC=1 PSA_FWU_SUPPORT=1"
    soc_extra_opt="STM32MP15=1"
    tf_a_make_target="all"

    # Create a tf-a binary that enables CAN for the M4 rather than the default A7
    # Backup, then modify dts file to move CAN i/f to M4
    dts=`find -L ${S} -name ${dtsBase}.dts`
    cp "${dts}" "${dts}.save"
    sed -i "s/DECPROT(STM32MP1_ETZPC_TT_FDCAN_ID, DECPROT_NS_RW/DECPROT(STM32MP1_ETZPC_TT_FDCAN_ID, DECPROT_MCU_ISOLATION/" "${dts}"

    # Build with modified dts
    mkdir -p "${B}/m4can-stm32mp15"
    oe_runmake -C "${S}" BUILD_PLAT="${B}/${config}${soc_suffix}" DTB_FILE_NAME="${dtsBase}.dtb" ${extra_opt} ${soc_extra_opt} ${tf_a_make_target}
    cp "${B}/${config}${soc_suffix}/${tfa_basename}-${dtsBase}.${TF_A_SUFFIX}" "${B}/${config}${soc_suffix}/${tfa_basename}-${dtsBase}-${config}.${TF_A_SUFFIX}"

    # Restore dts
    mv "${dts}.save" "${dts}"
}

do_deploy:append() {
    # The following are hard coded values and this may break if modified elsewhere.
    dtsBase="stm32mp157a-right_cost_display-mx"
    config="m4can"
    soc_suffix="-stm32mp15"
    tfa_basename="tf-a"

    install -m 644 "${B}/${config}${soc_suffix}/${tfa_basename}-${dtsBase}-${config}.${TF_A_SUFFIX}" "${DEPLOYDIR}/arm-trusted-firmware/"
}