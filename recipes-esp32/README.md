# RCD WLAN Module (Espressif ESP32 Module)

Recipes in this category all relate to support for the WLAN module on the Right Cost Display. This module provides WiFi and Bluetooth hardware to the RCD using [Espressif's ESP-Hosted solution](https://github.com/espressif/esp-hosted).

## esp-hosted

Installs the esp-hosted kernel driver.

## esp-support

Installs the firmware binaries, startup script, and the Espressif provided python scripts and shared C library.

### Firmware

Installs the binaries of the esp32 module firmware to be flashed on the module. See the [documentation](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/meta-hlio-rcd?path=/docs/WLAN_ESP32_Module.md&anchor=esp32-module-firmware&_a=preview) for details on how these are generated.

### tools

Initialization script for updating the ESP32 module firmware and starting the module during board initialization.

## esp-systemd

Systemd services for running the esp32 module startup script and creating the node device.

## protobuf

A temporary necessity to update the vesrion of protobuf installed on the board for compatibility with the esp-hosted kernel driver.

