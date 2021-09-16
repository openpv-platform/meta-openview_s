FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
   file://0001-Update-device-tree-to-use-sdmmc3-for-esp32.patch \
   file://0002-Apply-device-tree-changes-to-157f.patch \
   "
