#!/bin/sh

# Note: The baud rate was originally attempted at 960000, mode set to dio & freq 40m
# NB: qio and probably qout do not work on our chip
echo python3 esptool.py -p /dev/ttySTM2 -b $1 --before default_reset --after hard_reset \
write_flash --flash_mode $2 --flash_freq $3 --flash_size detect \
0x1000 ../firmware/esp_hosted_bootloader_esp32_sdio.bin \
0x8000 ../firmware/esp_hosted_partition-table_esp32_sdio.bin \
0xd000 ../firmware/esp_hosted_ota_data_initial.bin \
0x10000 ../firmware/esp_hosted_firmware_esp32_sdio.bin

python3 esptool.py -p /dev/ttySTM2 -b $1 --before default_reset --after hard_reset \
write_flash --flash_mode $2 --flash_freq $3 --flash_size detect \
0x1000 ../firmware/esp_hosted_bootloader_esp32_sdio.bin \
0x8000 ../firmware/esp_hosted_partition-table_esp32_sdio.bin \
0xd000 ../firmware/esp_hosted_ota_data_initial.bin \
0x10000 ../firmware/esp_hosted_firmware_esp32_sdio.bin
