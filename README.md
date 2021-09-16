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

- Currently we are piggy-backing on the ST provided _Machine_ and _Distro_. So the script to source is:

  `DISTRO=openstlinux-weston MACHINE=stm32mp1 source layers/meta-st/scripts/envsetup.sh`

  TBD: This will change once we create the Helios RCD specific machine definition and one or more specific distributions.

#### Making changes to the meta-hlio-rcd layer

All changes should be captured in the meta-hlio-rcd layer. This layer exists in the ST Yocto build environment under __layers/meta-st/meta-hlio-rcd__. Several existing recipes are already in place in this layer:
  - recipes-kernel - For kernel related changes, currently limited to device tree changes to the ST DK2 device tree.
    - TBD: When we create our own machine, the device tree will be entirely our own
  - recipes-esp32/esp-hosted
    - This is a good example of a recipe that adds a kernel driver that is not supported by OpenEmbedded.
    - Documentation on how this is done is found in [Adding an OpenEmbedded supported kernel driver]
  - recipes-hlio
    - These will contain image and distro definitions as well as adding OpenEmbedded supported drivers added through package groups.

The [meta-hlio-rcd repository](https://github.com/HLIO-SLivingston/meta-hlio-rcd)  
  - We will be using a Git-Flow workflow to maintain changes in the meta-hlio-rcd layer.
    - The `repo` tool used to check out the entire Yocto build environment is currently tied to the HEAD of the main branch of the repository. This will be changed to specific releases for Development Packages.
    - All development work should be done on feature and bug fix branches off of the `dev` branch. Release branches will be created when we are approaching a stable build that is ready for release. This release branch will then be merged into the main branch where it will be tagged and referenced in a release specific `repo` manifest in the [hlio-rcd-manifest](https://github.com/HLIO-SLivingston/hlio-rcd-manifest) repository.

  - When the developer has used `repo` to create the Yocto build environment, the meta-hlio-rcd layer will have a git status of "Not currently on any branch." and `git branch` will show "* (no branch)". 
  - Normal `git` commands can be invoked in this directory, but some steps are necessary to set up the appropriate tracking branches locally. 
  - The name of the remote is __github-private__.  
  - Before making a change in the build environment, it is a good idea to create your working branch off of the dev branch:  
    ```git
    git checkout -b <new_branch> github-private/dev
    .
    . [Make changes, and intermediate check-ins as needed]
    .
    git push github-private HEAD
    ```
    The push command as written above is needed to create the new branch in the repository.  
  - You may also want to have a local tracking branch for the remote dev branch, for merging purposes:  
`git checkout -b dev github-private/dev`

### Further Documentation

The following documentation is available for Distribution Team developers:

#### Documentation related to the Linux Kernel

- TBD: Modifying the Kernel

- Modifying the Device Tree

- Adding an OpenEmbedded supported kernel driver

- Adding an unsupported (by OpenEmbedded) kernel driver

#### Other Recipes and Applications

- TBD: Adding an existing OpenEmbedded recipe

## Maintainers
  - Steve Livingston <stephen.livingston@hlioengineering.com>
