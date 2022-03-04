# WLAN (ESP32) Module

- Most relevant recipes are in __recipes-esp32__.
- Python Recipes
  - ESP-Hosted python support scripts require python3-gpiod and version 3.13+ of python3-protobuf. These recipes are in recipes-python. (Our version of openembedded provides a python3-protobuf recipe, but it grabs v. 3.11. S.Livingston remembers but can no longer find reference where esp says it needs 3.13 or greater.)

## ESP-HOSTED Linux Kernel Driver
### Recipe is in recipes-esp32/esp-hosted
- The only patch applied at this point is to the Makefile to use our cross compiler in the Yocto build environment.
  - This patch had to be modified when moving from 0.3 to 0.4, so currently both patches are available in the files for easy transition to 0.4.
- The recipe has to be changed to the new branch/tag when upgrading.

## ESP32 Module Firmware

### Building Firmware

#### [Forked Espressif Repository](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/esp-hosted.git) is a Sub-module of [hlio-rcd-application-sdk](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/hlio-rcd-application-sdk) 

#### Original version was 0.3
- [ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-setup.html)
  - release/v4.0 (be7df8bce9c12c020d772ef1e71a773025f5177a)
    - Note: this is a branch and will receive further bug fix commits
    - Last working was commit 7504329ef9fb01f01a382416af7453c54b47fb2b
- esp-hosted
  - Commit 80ef3f61ce64e568484e195426a44b8b5cc5ee55
    - Version 0.3 with an addition commit to fix a bug

#### Upgrade to 0.4
- esp-hosted
  - release/v0.4 (74e707b604280ecb2eafa60ba5ed6993ce57b457)
    - Note: This is a tag, and is a fixed commit

Procedure:  
We have forked esp-hosted as esp-hosted.git and included this fork as a sub-module of the [hlio-rcd-application-sdk](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/hlio-rcd-application-sdk) repository.  
If any patches become necessary, they should be accomplished in this forked repository and then applied by updating this sub-module.

This is the procedure to build directly from the Espressif repository, but the procedure should be similar for building from our own repository.
- Create working directory, hereafter assumed to be `~/esp`.
- Prerequisites for Ubuntu
  - `sudo apt-get install git wget flex bison gperf python3 python3-pip python3-setuptools cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0`
- Clone the release/4.0 branch of ESP-IDF into ~/esp
  - __NB: Instructions for esp hosted say to use esp-idf v4.0 for ESP32__
  - `cd ~/esp`
  - `git clone -b release/v4.0 --recursive https://github.com/espressif/esp-idf.git`
- Enable protocomm for protobuf communication with host
  - `git mv components/protocomm/src/common/protocomm_priv.h components/protocomm/include/common/`
- Install esp-idf
  - `cd ~/esp/esp-idf`
  - `git submodule update --init --recursive`
  - `./install.sh`
- Get ESP-Hosted Code repository
  - We should use the forked repository as a sub-module of the [hlio-rcd-application-sdk repository](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/hlio-rcd-application-sdk)
  - If you are updating to a newer version from Espressif, you will need to rebase the rcd branch to that commit:
    - from top directory of the -sdk repo: `cd ./esp32/esp-hosted`
    - Example rebase: `git rebase release/v0.4`
    - Local changes will likely cause conflicts, which you will need to resolve. At a minimum, the Makefile for the c_support module has changed.
    - After rebasing and resolving conflicts, the current rcd-branch will have diverged. The path I decided to take is to create a new branch for the new version of esp-hosted:
      - `git checkout -b release/v0.4-rcd-develop`
      - `git push origin HEAD`
      - `git branch -u origin/release/v0.4-rcd-develop`
  - Make sure after updating the sub-module, to commit and push these changes to the remote Helios fork.
  - Then update the -sdk repository to use this specific commit of the sub-module:
    - 
  - Alternatively, to obtain directly from Espressif:
    - `git clone --recurse-submodules https://github.com/espressif/esp-hosted.git`
    - `cd esp-hosted`
    - `git submodule update --init --recursive`
    - Checkout branch:
      - Release 0.3:
        - `git checkout 80ef3f61ce64e568484e195426a44b8b5cc5ee55`
      - Release 0.4:
        - `git checkout release/v0.4`
    - `git submodule update --init --recursive`
- Source compilation
  - Set up build environment with script
    - `. $HOME/esp/esp-idf/export.sh`
  - cd <esp-hosted directory>
    - e.g. from top directory of the -sdk repo: `cd ./esp32/esp-hosted`
  - cd to the network_adapter application:
    - `cd ./esp/esp_driver/network_adapter`
  - `idf.py menuconfig`
    - Verify SDIO is selected: 
      - Example Configuration --> Transport layer --> SDIO interface --> select
    - Lower max dBm for WiFi to 12dBm
      - Component config --> PHY --> Max WiFi TX power (dBm)
  - Build
    - `idf.py build`

#### Testing New Firmware
- You can copy the binaries directly to the target board:
```
scp build/bootloader/bootloader.bin root@192.168.7.1:/lib/esp32/firmware/esp_hosted_bootloader_esp32_sdio.bin
scp build/partition_table/partition-table.bin root@192.168.7.1:/lib/esp32/firmware/esp_hosted_partition-table_esp32_sdio.bin
scp build/ota_data_initial.bin root@192.168.7.1:/lib/esp32/firmware/esp_hosted_ota_data_initial.bin
scp build/network_adapter.bin root@192.168.7.1:/lib/esp32/firmware/esp_hosted_firmware_esp32_sdio.bin
```
- Modify the on-board service to update to the correct firmware,
  - On the target board, the service is defined in:
    - `/lib/systemd/system/esp-firmware.service`
  - pass the new version in the service in the line:
    - `ExecStart=/lib/esp32/tools/esp32_init.sh 0.3`
    - E.g. __0.3__ becomes __0.4__
- You can reboot the board and verify successful update with:
  - `systemctl status esp-firmware`

#### __NB: The kernel module will also have to be updated to match, see [Add_Kernel_Driver.md](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/meta-hlio-rcd?path=/docs/Add_Kernel_Driver.md).__

#### Publishing the Firmware change:
The 4 output files need to be placed in the meta-hlio-rcd layer:
- Modify the version number in the following commands (currently "v0.3" if the firmware version changes)
```
cp build/bootloader/bootloader.bin <path-to-layer>/recipes-esp32/esp-support/files/firmware/esp_hosted_bootloader_esp32_sdio_v0.4.bin
cp build/partition_table/partition-table.bin <path-to-layer>/recipes-esp32/esp-support/files/firmware/esp_hosted_partition-table_esp32_sdio_v0.4.bin
cp build/ota_data_initial.bin <path-to-layer>/recipes-esp32/esp-support/files/firmware/esp_hosted_ota_data_initial_v0.4.bin
cp build/network_adapter.bin <path-to-layer>/recipes-esp32/esp-support/files/firmware/esp_hosted_firmware_esp32_sdio_v0.4.bin
```
- Also update the recipe to reflect any firmware version change:
  - recipes-esp32/esp-support/esp-support.bb
    - ESP_FW_VER = "v0.3"
- Finally, update the systemd service to expect the appropriate firmware version. You will also want to confirm that this systemd service is still looking for the right output from the esp32 module.
  - recipes-esp32/esp-systemd/esp-systemd/esp-firmware.service
    - ExecStart=/lib/esp32/tools/esp32_init.sh 0.3


### Automatic Flashing of Firmware
1. A systemd service will check the current version of firmware and update if not matching.  
  In file: `recipes-esp32/esp-systemd/esp-systemd/esp-firmware.service`  
    * Change the expected version to match the newly displayed version.  
      For example:  
      `ExecStart=/lib/esp32/tools/esp32_init.sh 0.3`  
      becomes  
      `ExecStart=/lib/esp32/tools/esp32_init.sh 0.4`  

## Support Tools
1. Espressif supplied python scripts are provided by recipe in the image  
    `/lib/esp32/python_support`
2. Our [hlio-rcd-application-sdk](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/hlio-rcd-application-sdk) provides a shared library and a command line interface.  
   See 

## Reference
- [ESP Hosted Overview - Linux Based Host](https://github.com/espressif/esp-hosted/blob/master/docs/Linux_based_host/Linux_based_readme.md)
- [User Guide for ESP-Hosted with Linux Host](https://github.com/espressif/esp-hosted/blob/master/docs/Linux_based_host/Getting_started.md)