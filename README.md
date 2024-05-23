# meta-hlio-rcd

## Summary

**meta-hlio-rcd** is a layer containing the Helios Engineering BSP metadata for modifying the ST distributed BSP.

The ST BSP relies on the OpenEmbedded/Yocto build system that is provided through
Bitbake and OpenEmbedded-Core layers.

This layer is a submodule of the [Ahsoka.BaseImages](https://enovation.visualstudio.com/Engineering/_git/Ahsoka.BaseImages) repository, which locates it in the `layers/meta-st/meta-hlio-rcd` path.

To build an image, start in the directory above `layers` and source the environment script. This sources all of the necessary toolchain for crosscompiling the image. All subsequent work (bitbake and devtool commands) must be done in the same console where the environment is sourced.

## Dependencies

* openstlinux **https://github.com/STMicroelectronics/meta-st-openstlinux**

* st-stm32mp **https://github.com/STMicroelectronics/meta-st-stm32mp**

* ESP-Hosted **https://github.com/espressif/esp-hosted**

## Pre-requisites
We are building based on the v4.1.0 ST Ecosystem (Kirkstone openembedded LTS, Linux Kernel 5.15 LTS).

Refer to the [ST PC prerequisites](https://wiki.st.com/stm32mpu-ecosystem-v4/wiki/PC_prerequisites) for this ecosystem for the complete PC requirements for building the BSP and related tools.

## Machine, Distro, and Images
### Primary BSP
This is the primary firmware package for the Openview series.
- __MACHINE__ = stm32mp1-hlio-rcd
- __DISTRO__ = hlio-rcd
- __image__ = hlio-image-rcd-base
- Source Environment script:
  - `DISTRO=hlio-rcd MACHINE=stm32mp1-hlio-rcd source layers/meta-st/scripts/envsetup.sh`
- Build BSP:
  - `bitbake hlio-image-rcd-base`
- A second image is available for this distro:
  - hlio-image-rcd-webkit: Adds webkit browser to the base image
### Over the Air update image
This is a special image intended to be loaded as a ramfs and used for field updates to the firmware.
- __MACHINE__ = stm32mp1-hlio-rcd-ota
- __DISTRO__ = hlio-rcd-ota
- __image__ = hlio-image-rcd-ota
- Source Environment script:
  - `DISTRO=hlio-rcd-ota MACHINE=stm32mp1-hlio-rcd-ota EULA_stm32mp1hliorcdota=1 source layers/meta-st/scripts/envsetup.sh`
- Build OTA image:
  - `bitbake hlio-image-rcd-ota`

## For Further Information
See the [DEVELOPER](./DEVELOPER.md) readme in this repository.
