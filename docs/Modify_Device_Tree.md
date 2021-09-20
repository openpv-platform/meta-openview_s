# Customize the device tree

For further reference, see [ST's walk-through](https://wiki.st.com/stm32mpu/wiki/How_to_customize_the_Linux_kernel).

All work is done in a terminal that has previously sourced the appropriate environment.

All commands are to be executed in the build directory unless otherwise indicated.

We can use devtool to facilitate kernel modifications.

## Prepare for any kernel modification:
  - `devtool modify virtual/kernel`
    - Creates __temporary layer, source tree and recipe__ in {Build Directory}/workspace
    - __Source tree__ extracted to {Build Directory}/workspace/sources/linux-stm32mp
    - __Recipe linux-stm32mp__ now set up to build from {Build Directory}/workspace/sources/linux-stm32mp

## Modify the device tree files
We may be able to mdoify these files directly in the repository once we create a machine definition, as we will no longer need to patch an ST device tree file. The following describes how to patch an existing file from another layer.
  - For example, I added an included .dtsi file and include it in the dk2 .dts file.
    - `stm32mp157c-hlio-rcb.dtsi`
    - Add `#include "stm32mp157c-hlio-rcb.dtsi"` to stm32mp157c-dk2.dts in the case of the dev kit

## Build with bitbake
  - `bitbake virtual/kernel -C compile`
    ```
    From ST: "We use here bitbake command instead of devtool build because the build makes compile, compile_kernemodules [sic] and install commands whereas we only need only [sic] compile command to generate the kernel image and the device tree".
    https://wiki.st.com/stm32mpu/wiki/How_to_cross-compile_with_the_Distribution_Package
    ```  

## Test
  - Copy the new Device Tree to the board and test:
    - `scp ./tmp-glibc/deploy/images/stm32mp1/kernel/*.dtb root@192.168.4.119:/boot`
      - Generally, `scp <build dir>/tmp-glibc/deploy/images/<machine name>/*.dtb root@<board ip address>:/boot`

## Create patches from these modifications
  - `cd workspace/sources/linux-stm32mp/`
    - Generally, `cd <build dir>/workspace/sources/<name of kernel recipe>/`
  - Check in changes to git, using standard git commands, typically `git add .` and `git commit -m "Commit message"`  
  It is necessary to create a git commit prior to the patch in order to use git format-patch:
  - `git format-patch -1`
    - In this case, the `-1` creates a patch for the last commit. If more than one change is made to the kernel, you can combine these steps by making multiple commits and then using `-n` to indicate the number of commits for which to create the patches. One patch will be created per commit.

## Add patches to a custom layer
We already have a layer defined for kernel modifications, so we just have to add the patch to the existing bbappend file. To create an original recipe, see [Creating an original append recipe](#creating-an-original-append-recipe)

From `$STM32DIST/layers/meta-st/meta-hlio-rcd`:
  - The path for our kernel recipe is:
    - `recipes-kernel/linux/linux-stm32mp_%.bbappend`  
    - The files directory `recipes-kernel/linux/linux-stm32mp` is for associated files, including the patches.
  - Copy the patch files into the source directory:
    - From the temporary workspace, in our case: `{Build Dir}/workspace/sources/linux-stm32mp/`:
    - Rename the patch files with new numbering from the git default if appropriate to maintain the recipe with sequential numbering.
    - `cp *.patch $STM32DIST/layers/meta-st/meta-hlio-rcd/recipes-kernel/linux/linux-stm32mp/`
      - Generally, `cp *.patch ../meta-my-custo-layer/recipes-kernel/linux/<name of kernel recipe>/`
  - Edit the recipe append file with references to the patch files:
      - `SRC_URI += "file://0001-first-change.patch"`

## Further Information

### Creating an original append recipe

The following steps were taken to create the original linux patch recipe:  
From the `$STM32DIST/layers/meta-st/meta-hlio-rcd` directory:  
  - Create the path for a kernel recipe if it does not already exist:
    - `mkdir recipes-kernel`
    - `mkdir recipes-kernel/linux`
    - `mkdir recipes-kernel/linux/linux-stm32mp`  
    This last directory is for associated files, including the patches.
  - Create the append file associated with the st provided kernel recipe:
    - `touch recipes-kernel/linux/linux-stm32mp_%.bbappend`
  - Edit this recipe append file:
    - Extend where bitbake will search for files:
      - `FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"`  
      We have named the source file directory according to the package name (${PN}).
  - From here, we followed the remaining instructions above under [add pathches](#add-patches-to-a-custom-layer)
