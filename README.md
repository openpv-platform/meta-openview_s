# meta-hlio-rcd

## Summary

**meta-hlio-rcd** is a layer containing the Helios Engineering BSP metadata for modifying the ST distributed BSP.

This layer relies on the OpenEmbedded/Yocto build system that is provided through
Bitbake and OpenEmbedded-Core layers. 

## Images

Currently provides two images:
* hlio-image-rcd-base: Base BSP for the Right Cost Display
* hlio-image-rcd-webkit: Adds webkit browser to the base image

## Dependencies

* openstlinux **https://github.com/STMicroelectronics/meta-st-openstlinux**

* st-stm32mp **https://github.com/STMicroelectronics/meta-st-stm32mp**

* ESP-Hosted **https://github.com/espressif/esp-hosted**

## Basic Development Steps

### Build Directory and Environment Script

- All work is done in a build directory that gets created by an environment script.

- Any subsequent work must be done in a terminal that has sourced the same script.

1. Development on the Helios RCD hardware:
    ```
    DISTRO=hlio-rcd MACHINE=stm32mp1-hlio-rcd source layers/meta-st/scripts/envsetup.sh
    ```
