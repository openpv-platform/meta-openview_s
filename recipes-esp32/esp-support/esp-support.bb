require conf/include/esp-hosted-srcrev.inc

DESCRIPTION = "Support files and scripts for esp-hosted"

LICENSE = "Enovation-Proprietary"
LIC_FILES_CHKSUM = "file://${STM32MP_META_HLIO_RCD_BASE}/licenses/Enovation-Controls-License.rtf;md5=7a35371310afae6d2edc9c24089f674f"

SRC_URI = " \
           file://firmware/esp_hosted_bootloader_esp32_sdio_${ESP_FW_VER}.bin \
           file://firmware/esp_hosted_partition-table_esp32_sdio_${ESP_FW_VER}.bin \
           file://firmware/esp_hosted_ota_data_initial_${ESP_FW_VER}.bin \
           file://firmware/esp_hosted_firmware_esp32_sdio_${ESP_FW_VER}.bin \
           file://tools/burnParam.sh \
           file://tools/burn.sh \
           file://tools/esp32_init.sh \
           file://tools/esptool.py \
           "

SRCREV = "${ESP_HOSTED_SRCREV}"

FILES:${PN} += "${base_libdir}/esp32/firmware/"
FILES:${PN} += "${base_libdir}/esp32/tools/*"

# Library for flashing module
RDEPENDS:${PN} += "libgpiod"
# Libraries for python script support
RDEPENDS:${PN} += "python3-core python3-pyserial python3-gpiod python3-protobuf"
# Library for testing WiFI
RDEPENDS:${PN} += "iperf3"
# Library for audio decoding and streaming for bluetooth
RDEPENDS:${PN} += "pulseaudio ffmpeg"

do_install () {
  # directory for esp32 related files
  install -d ${D}${base_libdir}/esp32/

  # Firmware binaries for esp32 module, rename to keep script generic
  install -d ${D}${base_libdir}/esp32/firmware/
  install -m 0700 ${WORKDIR}/firmware/esp_hosted_bootloader_esp32_sdio_${ESP_FW_VER}.bin ${D}${base_libdir}/esp32/firmware/esp_hosted_bootloader_esp32_sdio.bin
  install -m 0700 ${WORKDIR}/firmware/esp_hosted_partition-table_esp32_sdio_${ESP_FW_VER}.bin ${D}${base_libdir}/esp32/firmware/esp_hosted_partition-table_esp32_sdio.bin
  install -m 0700 ${WORKDIR}/firmware/esp_hosted_ota_data_initial_${ESP_FW_VER}.bin ${D}${base_libdir}/esp32/firmware/esp_hosted_ota_data_initial.bin
  install -m 0700 ${WORKDIR}/firmware/esp_hosted_firmware_esp32_sdio_${ESP_FW_VER}.bin ${D}${base_libdir}/esp32/firmware/esp_hosted_firmware_esp32_sdio.bin

  # Script for flashing module
  install -d ${D}${base_libdir}/esp32/tools/
  install -m 0700 ${WORKDIR}/tools/* ${D}${base_libdir}/esp32/tools/

}
