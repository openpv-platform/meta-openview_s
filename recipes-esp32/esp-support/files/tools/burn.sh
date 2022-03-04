#!/bin/sh

echo python3 esptool.py -p /dev/ttySTM2 -b 960000 --before default_reset --after hard_reset \
write_flash --flash_mode dio --flash_freq 40m --flash_size detect \
0x1000 ../firmware/esp_hosted_bootloader_esp32_sdio.bin \
0x8000 ../firmware/esp_hosted_partition-table_esp32_sdio.bin \
0xd000 ../firmware/esp_hosted_ota_data_initial.bin \
0x10000 ../firmware/esp_hosted_firmware_esp32_sdio.bin

python3 esptool.py -p /dev/ttySTM2 -b 960000 --before default_reset --after hard_reset \
write_flash --flash_mode dio --flash_freq 40m --flash_size detect \
0x1000 ../firmware/esp_hosted_bootloader_esp32_sdio.bin \
0x8000 ../firmware/esp_hosted_partition-table_esp32_sdio.bin \
0xd000 ../firmware/esp_hosted_ota_data_initial.bin \
0x10000 ../firmware/esp_hosted_firmware_esp32_sdio.bin
