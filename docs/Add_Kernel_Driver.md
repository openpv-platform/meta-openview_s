# Add an external kernel module
- See also [devtool Quick Reference](http://docs.yoctoproject.org/3.1.10/ref-manual/ref-devtool-reference.html?highlight=src_uri%20git%20tag)
- Example is esp32 host driver
- First approach is to integrate the work entirely within the Yocto project  
In the {build} directory of the yocto project.
  - Create a working directory of a new recipe
    - NB: This is a temporary working directory to test the build as you develop.
    - `devtool add --srcrev 80ef3f61ce64e568484e195426a44b8b5cc5ee55 git://github.com/espressif/esp-hosted.git`
      - In our case, we are using --srcrev to pick out a specific revision of the code based on the commit hash. See the note below, this is the nearest revision to an official ESP release with a fix to work with Linux Kernels 5.6 and above.
      - To use a tag, the command would be the same with the distro tag:
        - `devtool add --srcrev release/v0.3 git://github.com/espressif/esp-hosted.git`
  - Modify the recipe as needed.
    - You can edit the recipe with an external editor or use `devtool edit-recipe {recipe name}`
      - `EDITOR=/snap/code/current/usr/share/code/bin/code devtool edit-recipe esp-hosted`
    - Since the build directory for the host driver is a sub-directory of the entire project, we have to add to the default path to direct yocto to build in that directory.
      - `S = "${WORKDIR}/git/host/linux/host_driver/esp32"`
      - NB: The temporary build directory depends on a recipe patch (bbappend) file to modify the final recipe to work in the tempoary build directory.
        - This file is located in {build}/workspace/appends/{recipe-name}.bbappend.
        - In our case we have to modify two lines that specific EXTERNALSRC to point to the correct sub-directory.
        ```
        EXTERNALSRC = "/home/slivings/STM32MPU_workspace/STM32MP15-Ecosystem-v3.0.0/Distribution-Package/openstlinux-5.10-dunfell-mp1-21-03-31/build-openstlinuxweston-stm32mp1/workspace/sources/esp-hosted/host/linux/host_driver/esp32"
        EXTERNALSRC_BUILD = "/home/slivings/STM32MPU_workspace/STM32MP15-Ecosystem-v3.0.0/Distribution-Package/openstlinux-5.10-dunfell-mp1-21-03-31/build-openstlinuxweston-stm32mp1/workspace/sources/esp-hosted/host/linux/host_driver/esp32"
        ```
  - Modify source as needed.
    - As the auto-generated recipe indicates, we have to patch the Makefile to use the correct Kernel Source Directory.
      - Modify the Makefile
        - The temporary working source directory is in {build}/workspace/sources/{recipe-name}
        - See the resulting patch file for details on the changes in this case:
          - Replace the ESP provided kernel source path and replace it with the Yocto provided variable ({KERNEL_SRC})
          - Remove the CROSS_COMPILE and ARCH directive as that is handled by YOCTO as well.
      - Create the patch:  
      In {build}/workspace/sources/{recipe-name}
        - `git add .`
        - `git commit -m "text will become name of patch file"`
        - `git format-patch -1`
      - Add the patch file to the recipe:
        - NB: Patches can be automatically created and added to the recipe by devtool in the "finish" command. All that needs to happen is to do a git commmit for each separate patch file desired. The patch is not necessary during the build and test process.
        - It also looks like `devtool update-recipe` will do this automatically (after git checkin), but I did not try this yet. I did it manually as follows:
        - Generically add a reference path to your patch files:
          - `FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"`
          - Store all patch files in a sub-directory of the recipe directory with the recipe name as the name ${PN} in the previous line.
        - Add the patch file to the SRC_URI:
          ```
          SRC_URI = " \
              gitsm://github.com/espressif/esp-hosted.git \
              file://0001-Update-Makefile-for-Yocto.patch \
              "
          ```
    - This process can be repeated for any source files that need to be patched.
  - Build to test
    - `devtool build esp-hosted`
    - This should produce output in multiple places that can then be tested on the target:
      ```
      ./tmp-glibc/work/stm32mp1-ostl-linux-gnueabi/esp-hosted/1.0+git999-r0/sysroot-destdir/lib/modules/5.10.10/extra/esp32_sdio.ko
      ./tmp-glibc/work/stm32mp1-ostl-linux-gnueabi/esp-hosted/1.0+git999-r0/image/lib/modules/5.10.10/extra/esp32_sdio.ko
      ./tmp-glibc/work/stm32mp1-ostl-linux-gnueabi/esp-hosted/1.0+git999-r0/packages-split/kernel-module-esp32-sdio-5.10.10/lib/modules/5.10.10/extra/esp32_sdio.ko
      ./tmp-glibc/work/stm32mp1-ostl-linux-gnueabi/esp-hosted/1.0+git999-r0/package/lib/modules/5.10.10/extra/esp32_sdio.ko
      ./workspace/sources/esp-hosted/host/linux/host_driver/esp32/esp32_sdio.ko
      ```
  - Preserve your changes in the custom layer:
    - `devtool finish esp-hosted ../layers/meta-st/meta-hlio-rcd/recipes-esp32`
      - Generically `devtool finish {recipe-name} {path-to-layer}`
      - Creates patches corresponding to commits in the local git repository
      - Updates the recipe
      - Resets the recipe to build normally rather than from workspace
  - Or, undo your work if not satisfied:
    - `devtool reset {recipe-name}`
    - Leaves source directory intact, which will have to be manually deleted if you plan to try again.
    - Add your new recipe to the actual image build by adding it to `IMAGE_INSTALL_append` in the layer.conf file.
  - You can auto-load this kernel module by adding it to KERNEL_MODULE_AUTOLOAD in the recipe:
    - `KERNEL_MODULE_AUTOLOAD += "esp32_sdio"`
  - Build image and confirm
    - `bitbake hlio-image-rcd`
    - **NB: I had to fix 3 issues with the esp-hosted_git.bb recipe:**
      - Patch file needed `striplevel` option because of mismatch between git repository root directory and compile directory. This sets the -p option referenced in the error without the change. See also `patchdir`.
        - `SRC_URI = "gitsm://github.com/espressif/esp-hosted.git \
          file://0001-Update-Makefile-for-Yocto.patch;striplevel=5"
      - LICENSE and LIC_FILES_CHKSUM had to be updated:
        - Deleted unnecessary licenses and license file references and deleted the path directories above the build directory. Only the license in the build directory is preserved.
      - Error with Package version "went backwards":
        - Ignored. Also changed our manual versioning to 0.3.2 to match espressif version with a patch version of 2.

- Modifying an existing recipe:
  - `devtool modify {recipe-name}`
    - This will create a bbappend and leave the original recipe with modifications.
  - Also see [Upgrading Recipes](http://docs.yoctoproject.org/3.1.10/dev-manual/dev-manual-common-tasks.html#upgrading-recipes)
  - And [devtool upgrade](http://docs.yoctoproject.org/3.1.10/sdk-manual/sdk-extensible.html#use-devtool-upgrade-to-create-a-version-of-the-recipe-that-supports-a-newer-version-of-the-software)

- Another approach for adding a kernel driver is to work with a local source tree, which would be applicable if we want to separate the handling of the ESP host driver separately from the overall yocto project.
  - Download source (Can be a tar ball)
    - Create sources directory in build directory  
    In layers/meta-st/meta-hlio-rcd/sources:
    - `git clone --recurse-submodules https://github.com/espressif/esp-hosted.git`
    - `cd esp-hosted/`
    - Use the latest tagged release:
      - `git checkout -b release/v0.3.2 80ef3f6`
      - __NB: I tried the v0.3 release but there is a compile error that gets fixed in the next commit.__
    - ESP-hosted uses git submodules:
      - `git submodule update --init --recursive`
  - Use devtool to create a recipe for this source  
    This is similar to the approach above, with the exception that the original command references the local source tree:
    - `devtool add esp-hosted ../layers/meta-st/meta-hlio-rcd/sources/esp-hosted/host/linux/host_driver/esp32/`
    - See above for subsequent steps, which should be the same.
    - Note, this approach would require the source directory to always be provided with the distribution
