# meta-hlio-rcd

## Summary

**meta-hlio-rcd** is a layer containing the Helios Engineering BSP metadata for modifying the ST distributed BSP.

This layer relies on the OpenEmbedded/Yocto build system that is provided through
Bitbake and OpenEmbedded-Core layers. 

## Images

Provides a single image:

* hlio-image-rcd: Base BSP for the Right Cost Display

## Dependencies

* openstlinux **https://github.com/STMicroelectronics/meta-st-openstlinux**

* st-stm32mp **https://github.com/STMicroelectronics/meta-st-stm32mp**

* ESP-Hosted **https://github.com/espressif/esp-hosted**


## Adding the meta-hlio-rcd layer to your build

Run 'bitbake-layers add-layer meta-hlio-rcd'

## Contributors

### Basic Development Steps

#### Build Directory and Environment Script

- All work is done in a build directory that gets created by an environment script.

- Any subsequent work must be done in a terminal that has sourced the same script.

There are currently two machine names available:  

1. Development on the ST Development Kit (DK):
    ```
    DISTRO=hlio-rcd MACHINE=stm32mp1 source layers/meta-st/scripts/envsetup.sh
    ```

2. Development on the Helios RCD hardware:
   - Do not use this yet, as the device tree has not been fully defined and may cause issues on the Dev Kit.
    ```
    DISTRO=hlio-rcd MACHINE=stm32mp1-hlio-rcd source layers/meta-st/scripts/envsetup.sh
    ```

3. Legacy prior to merge of DISTRO changes:
    ```
    DISTRO=openstlinux-weston MACHINE=stm32mp1 source layers/meta-st/scripts/envsetup.sh
    ```
    - Followed by a one-time command:  
    `bitbake-layers add-layer ../layers/meta-st/meta-hlio-rcd/`

#### Making changes to the meta-hlio-rcd layer

All changes should be captured in the meta-hlio-rcd layer. This layer exists in the ST Yocto build environment under __layers/meta-st/meta-hlio-rcd__. Several existing recipes are already in place in this layer:
  - recipes-kernel - For kernel related changes, currently limited to device tree changes to the ST DK2 device tree.
    - TODO: When we create our own machine, the device tree will be entirely our own
  - recipes-esp32/esp-hosted
    - This is a good example of a recipe that adds a kernel driver that is not supported by OpenEmbedded.
    - Documentation on how this is done is found in [Adding an OpenEmbedded supported kernel driver]
  - recipes-hlio
    - These will contain image and distro definitions as well as adding OpenEmbedded supported drivers which get added through package groups.

The meta-hlio-rcd repository
  - We will be using a Git-Flow workflow to maintain changes in the meta-hlio-rcd layer.
    - The `repo` tool used to check out the entire Yocto build environment is currently tied to the HEAD of the main branch of the repository. This will be changed to specific releases for Development Packages.
    - All development work should be done on feature and bug fix branches off of the `dev` branch. Release branches will be created when we are approaching a stable build that is ready for release. This release branch will then be merged into the main branch where it will be tagged and referenced in a release specific `repo` manifest in the [hlio-rcd-manifest](https://enovationexternal.visualstudio.com/HCEE/_git/hlio-rcd-manifest) repository.

  - When the developer has used `repo` to create the Yocto build environment, the meta-hlio-rcd layer will have a git status of "Not currently on any branch." and `git branch` will show "* (no branch)". 
  - Normal `git` commands can be invoked in this directory, but some steps are necessary to set up the appropriate tracking branches locally. 
  - The name of the remote is __hlio-devops__.  
  - Before making a change in the build environment, create your working branch off of the dev branch. Please use the following naming convention:
    - new_branch_name = "dev/{developer-name}/{pbi#-feature-name}"
    ```git
    git checkout -b <new_branch_name> hlio-devops/dev
    .
    . [Make changes, and intermediate check-ins as needed]
    .
    git push hlio-devops HEAD
    git branch <name_of_new_branch> -u hlio-devops/<name_of_new_branch>
    ```
    - The checkout command above creates the new local branch based off of and tracking the current remote dev branch.
    - The push command above is needed to create the new branch in the repository.
    - The branch command that follows will change your local tracking branch to track the newly created remote branch instead of hlio-devops/dev.
      - The -t switch with the original checkout command will not work because the remote branch does not exist yet.
      - There may be other ways with git to accomplish this. Please submit suggestions if there is something more succinct or cleaner.
  - You may also want to have a local tracking branch for the remote dev branch, for merging purposes:  
`git checkout -b dev hlio-devops/dev`

### Further Documentation

The following documentation is available for Distribution Team developers:

#### Documentation related to the Linux Kernel

- TODO: Modifying the Kernel

- [Modifying the Device Tree](https://enovationexternal.visualstudio.com/HCEE/_git/meta-hlio-rcd?path=/docs/Modify_Device_Tree.md&version=GBmain&_a=preview)

- Adding an OpenEmbedded supported kernel driver
  - Add `IMAGE_INSTALL_append = " python3-pip"` to `layers/meta-st/meta-hlio-rcd/conf/layer.conf` config file

- [Adding an unsupported (by OpenEmbedded) kernel driver](https://enovationexternal.visualstudio.com/HCEE/_git/meta-hlio-rcd?path=/docs/Add_Kernel_Driver.md&version=GBmain&_a=preview)

#### Other Recipes and Applications

- TODO: Adding an existing OpenEmbedded recipe

## Maintainers
  - Steve Livingston <stephen.livingston@hlioengineering.com>
