# Package Version based on ESP release
ESP_HOSTED_PV:esp-hosted-orig = "0.4"
ESP_HOSTED_PV:esp-hosted-fg = "0.0.5"
ESP_HOSTED_PV:esp-hosted-ng = "1.0.2"

# Version identifier used for file naming
ESP_FW_VER = "v${ESP_HOSTED_PV}"

# SHA tagged release
ESP_HOSTED_SRCREV:esp-hosted-orig = "74e707b604280ecb2eafa60ba5ed6993ce57b457"
ESP_HOSTED_SRCREV:esp-hosted-fg = "3769eea28bbbc59d8ea2aff425d62564b7fb3e68"
ESP_HOSTED_SRCREV:esp-hosted-ng = "29208b6c156be06dfd90dadc6dd43acd4d98d748"

# Makefile Patch
ESP_MAKEFILE_PATCH:esp-hosted-orig = "file://0001-Update-Makefile-for-Yocto-orig.patch;striplevel=5"
ESP_MAKEFILE_PATCH:esp-hosted-fg = "file://0001-Update-Makefile-for-Yocto-fg.patch;striplevel=6"
ESP_MAKEFILE_PATCH:esp-hosted-ng = "file://0001-Update-Makefile-for-Yocto-ng.patch;striplevel=3"

# License Path/checksum; path is relative to S_PATH below
ESP_LIC_FILES_CHKSUM:esp-hosted-orig = "file://LICENSE;md5=8264535c0c4e9c6c335635c4026a8022"
ESP_LIC_FILES_CHKSUM:esp-hosted-fg = "file://../../LICENSE;md5=e6a75371ba4d16749254a51215d13f97"
ESP_LIC_FILES_CHKSUM:esp-hosted-ng = "file://../../LICENSES/GPL-2.0;md5=e6a75371ba4d16749254a51215d13f97"

# S (Working directory Source Code Path)
ESP_S_PATH:esp-hosted-orig = "host/linux/host_driver/esp32"
ESP_S_PATH:esp-hosted-fg = "esp_hosted_fg/host/linux/host_driver/esp32"
ESP_S_PATH:esp-hosted-ng = "esp_hosted_ng/host"

# Pick which release - override in local.conf or command line if desired
# Command line example: 
# BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS ESP_HOSTED_VERSION" ESP_HOSTED_VERSION="esp-hosted-ng" bitbake hlio-image-rcd-base
ESP_HOSTED_VERSION ?= "esp-hosted-orig"
