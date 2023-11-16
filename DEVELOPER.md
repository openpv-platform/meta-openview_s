# Developers Guide to meta-hlio-rcd


## Making changes to the meta-hlio-rcd layer

All changes should be captured in the meta-hlio-rcd layer. This layer exists in the ST Yocto build environment under __layers/meta-st/meta-hlio-rcd__.  

Device tree files are found in `mx/CA7/DeviceTree/right_cost_display/`  

Recipes are organized for the most part according to the open-embedded recipe that they modify. Our own recipes are under:
  - recipes-kernel
    - For kernel and hardware related changes
  - recipes-esp32
    - The Wifi/Bluetooth module kernel driver & associated support
  - recipes-hlio
    - This contains image and distro definitions as well as package groups.
    - This also contains all startup related recipes

## The [meta-openview_s](https://enovation.visualstudio.com/Engineering/_git/meta-openview_s) repository

This layer is referenced as a submodule of the [Ahsoka.BaseImages](https://enovation.visualstudio.com/Engineering/_git/Ahsoka.BaseImages) repository, which locates it in the `layers/meta-st/meta-hlio-rcd` path.  When a new BSP release is ready, the Ahsoka.BaseImages repository has to be updated to reference the appropriate commit.

  - All development work should be done on features/ branches off of the `kirkstone` branch.

  - When the developer has used the Ahoska.BaseImages repository to create the Yocto build environment, the meta-hlio-rcd layer will have a git status of "HEAD detached."
    - Normal `git` commands can be invoked in this directory, but some steps are necessary to set up the appropriate tracking branches locally. 
    - The name of the remote is __origin__.  
    - Before making a change in the build environment, create your working branch off of the kirkstone branch. Please use the following naming convention:
      - new_branch_name = "features/{developer-initials}-{feature-name}"
      ```git
      git checkout -b <new_branch_name> origin/kirkstone
      .
      . [Make changes, and intermediate check-ins as needed]
      .
      git push origin HEAD
      git branch <name_of_new_branch> -u origin/<name_of_new_branch>
      ```
      - The checkout command above creates the new local branch based off of and tracking the current remote kirkstone branch.
      - The push command above is needed to create the new branch in the repository.
      - The branch command that follows will change your local tracking branch to track the newly created remote branch instead of origin/kirkstone.
        - The -t switch with the original checkout command will not work because the remote branch does not exist yet.
        - There may be other ways with git to accomplish this. Please submit suggestions if there is something more succinct or cleaner.
    - You may also want to have a local tracking branch for the remote dev branch, for merging purposes:  
  `git checkout -b kirkstone origin/kirkstone`

## Build Pre-Requisites
* ST recommends building on an Ubuntu 20.4 or 22.04 Linux host, and building in WSL2 is considered experimental. We have had success building in WSL2 and in an Ubuntu docker image. ST recommends 500GB disk space, we recommend a minimum of __150GB__ for anyone expecting to work in the distribution package.

* Because we are currently using private repositories, it is necessary to have associated an [SSH key with your DevOps](https://docs.microsoft.com/en-us/azure/devops/repos/git/use-ssh-keys-to-authenticate?view=azure-devops#:~:text=Set%20up%20SSH%20key%20authentication%201%20Create%20your,...%203%20Clone%20the%20Git%20repository%20with%20SSH).  
  If you struggle with getting the permissions correct on your key(s), please refer [here](https://community.perforce.com/s/article/6210#:~:text=ssh%20directory%20permissions%20should%20be,%2D%2D%2D%2D%2D)  

* We recommend following [ST PC prerequisites](https://wiki.st.com/stm32mpu-ecosystem-v4/wiki/PC_prerequisites) for the v4.1 ecosystem for the complete PC requirements for building the BSP and related tools. The following commands were gathered from the Dunfell release from ST and need to be updated to reflect any changes for Ubuntu 22.04 and/or the Kirkstone build ecosystem.
  
  - Upgrade Ubuntu and Install Development Tools  
  `sudo apt-get update -y && sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 pylint xterm -y && sudo apt-get install make xsltproc docbook-utils fop dblatex xmlto -y && sudo apt-get install libmpc-dev libgmp-dev -y && sudo apt-get install libncurses5 libncurses5-dev libncursesw5-dev libssl-dev linux-headers-generic u-boot-tools device-tree-compiler bison flex g++ libyaml-dev libmpc-dev libgmp-dev -y && sudo apt-get install coreutils bsdmainutils sed curl bc lrzsz corkscrew cvs subversion mercurial nfs-common nfs-kernel-server libarchive-zip-perl dos2unix texi2html diffstat libxml2-utils -y`  
  - Setup SSH Server (Optional)  (Sourced from [here](https://www.cyberciti.biz/faq/ubuntu-linux-install-openssh-server/))  
  `sudo apt-get install openssh-server -y`  
  `sudo systemctl enable ssh`  
  `sudo systemctl start ssh`  
  If you want to leverage your ssh key instead of password, [this](https://lani78.com/2012/07/21/generate-a-ssh-key-and-disable-password-authentication-on-ubuntu-server-12-0/) is a good reference.  

## Building the Firmware Image

All work is done with command line tools in a terminal.

The distro, machine and image information is presented in the primary [README.md](./README.md#machine-distro-and-images) so we will not reproduce that here.

### A. Source the environment script
This is necessary any time that a new terminal window is opened in which you plan to run bitbake and devtool commands.  

**NB: This creates a build directory in your project directory with a name of build_{distro-name}_{machine_name}. This is hereafter referred to as the `{build-directory}`.**  
The script also moves you into the {build-directory}, where you will execute most commands to build images or modify source code with devtool.

- `DISTRO=hlio-rcd MACHINE=stm32mp1-hlio-rcd source layers/meta-st/scripts/envsetup.sh`

For early development purposes, we used the ST Development Kit (DK2)
- `DISTRO=hlio-rcd MACHINE=stm32mp1 source layers/meta-st/scripts/envsetup.sh`

### B. Build the image
Caution, this step will take a very long time (2-3 hours) the first time.  
After sourcing the environment, you are now in the {build-directory}.  
- `bitbake hlio-image-rcd-base`

## Flashing the Firmware Image

### A. Pre-requisites

1. Requires the ST [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html#getsoftware-scroll)

2. Requires raw access for the programmer to the USB port  
    See [4.2 USB serial link](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2/Let%27s_start/Populate_the_target_and_boot_the_image#) for further reference.  
   - The libusb library is necessary for programmer control of the USB port
      ```
      sudo apt-get install libusb-1.0-0
      ```
    - After installing the programmer, copy the programmer's udev rules:
      ```
      sudo cp {STM32CubeProgrammer Directory}/Drivers/rules/*.* /etc/udev/rules.d/
      ```

### B. Flash the Image
The flash layout file (.tsv) and the path to the binaries is specific to our build:  
- The flash layout file (opened in the top pane):  
  - `{build-directory}/tmp-glibc/deploy/images/stm32mp1-hlio-rcd/flashlayout_hlio-image-rcd-base/trusted/FlashLayout_emmc_stm32mp157a-right_cost_display-mx-trusted.tsv`
- The path to the binaries (loaded in the lower pane):  
  - `{build-directory}/tmp-glibc/deploy/images/stm32mp1-hlio-rcd/`

## Over the Air Updates Image
This image is new as of October, 2023. So some of the information below is specific to conditions as of 10/13/2023. We will need to update this as any approach changes.
### Build the Image
Because this uses a different machine and distro, this must be done in a separate console from the firmware image and the environment script sourced separately.  

Note: If both images are being built, you can locally reduce build time and disk usage by pointing the ota build to the same sstate-cache and download directories as the base firmware image on your local build machine. This is done in your local build directory `conf/local.conf` file after sourcing the environment script.
- Build the image:
  ```
  DISTRO=hlio-rcd-ota MACHINE=stm32mp1-hlio-rcd-ota source layers/meta-st/scripts/envsetup.sh
  bitbake hlio-image-rcd-ota
  ```

### Build Output
The output from building the OTA image (hlio-image-rcd-ota) is a cpio formatted archive filesystem.  
- Path:
  - `tmp-glibc/deploy/images/stm32mp1-hlio-rcd-ota/`
- Image name {image}-{distro}-{machine}.cpio:
  - `hlio-image-rcd-ota-hlio-rcd-ota-stm32mp1-hlio-rcd-ota.cpio`

### Post Build Process

There are several support scripts in the meta-hlio-rcd layer under `ota-files`.
#### Prepare Ramdisk
- `prepare-ramdisk.sh` is used to post-process the cpio output from the image build.

You can use this script to convert the cpio file into a uRamdisk for loading by u-boot. The script behavior is defaulted to be run from the build directory and it will produce its output in the `layers/meta-st/meta-hlio-rcd/ota-files/deploy` directory. The script will also accept parameters to point to the cpio file and the deploy output directory.  
Example, from {build-directory}: `../layers/meta-st/meta-hlio-rcd/ota-files/prepare-ramdisk.sh`

This will produce 2 outputs in the deploy directory:
  - `uRamdisk` is the full image in ramfs format for loading by u-boot
  - `uImage-ota` is the Linux kernel binary extracted from the cpio filesystem for direct loading by u-boot

### OTA Process
There are currently two functioning approaches to booting to the ota image. Both require placing the two post-build process outputs referenced above into the display's /boot directory.  

#### Deploy Binaries, Scripts and Configurations
Use the `deploy.sh` script in the meta-hlio-rcd/ota-files directory. This will also provide the u-boot environment configuration as well as a utility for swapping the boot command.  
Files:
  - Linux Kernel
    - `./deploy/uImage-ota` --> `/boot/uImage-ota`
  - Root and boot filesystem in ramfs format
    - `./deploy/uRamdisk` --> `/boot/uRamdisk`
  - default u-boot environment text file
    - `./uboot-env-original` --> `/etc/u-boot-initial-env`
  - u-boot environment configuration for fw_setenv & fw_printenv
    - `../recipes-uboot/u-boot/files/fw_env.config` --> `/etc/fw_env.config`
  - Script to modify boot command for boot [option 1](#boot-option-1-u-boot-boot-command) below
    - `./boot-cmd.sh` --> `/boot/boot-cmd.sh`
  - Script to modify extlinux.conf for boot [option 2](#boot-option-2-extlinuxconf) below
    - `./extlinux-boot.sh` --> `/boot/extlinux-boot.sh`
    - `./extlinux.conf.ota` --> `/boot/extlinux.conf.ota`
    - Example usage, script must be run from /boot on the display:
      - Change to boot ota image: `./extlinux-boot.sh ota`
      - Change to boot flash image - more complicated because the files are on an unmounted partition:
        ```shell
        mkdir /home/root/boot
        mount /dev/mmcblk1p6 /home/root/boot
        cd /home/root/boot/ && ./extlinux-boot.sh flash
        cd && umount /home/root/boot/
        ```

#### Boot Option 1: u-boot Boot Command
Use the `boot-cmd.sh` script run on the Openview display to modify the u-boot environment boot command. The `deploy.sh` script places this script in /boot.
  - '`/boot/boot-cmd.sh ota`' will cause u-boot to boot to the OTA image.
  - '`/boot/boot-cmd-sh flash`' will restore the original boot command to boot from flash

#### Boot Option 2: extlinux.conf
Modify the extlinux.conf file in `/boot/extlinux/extlinux.conf`.
- extlinux.conf for booting OTA:
  ```
  TIMEOUT 0
  LABEL Hlio-RCD
      KERNEL /uImage-ota
      FDTDIR /
      FDTOVERLAYS /overlays/active_7-inch-screen-overlay.dtbo /overlays/active_m4-can-overlay.dtbo
      INITRD /uRamdisk
      APPEND rootwait rw oonsole=ttySTM0,115200
  ```
- extlinux.conf for booting from flash (default):
  ```
  TIMEOUT 0
  LABEL Hlio-RCD
      KERNEL /uImage
      FDTDIR /
      FDTOVERLAYS /overlays/active_7-inch-screen-overlay.dtbo /overlays/active_m4-can-overlay.dtbo
      APPEND root=PARTUUID=491f6117-415d-4f53-88c9-6e0de54deac6 rootwait rw quiet init="/sbin/hlio-init.sh"  console=ttySTM0,115200
  ```

## Further Documentation
Additional documentation is available for Team developers on this [Right Cost Display Wiki](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_wiki/wikis/Right-Cost-Display.wiki/23/Right-Cost-Display-Wiki).

