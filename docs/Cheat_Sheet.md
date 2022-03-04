# DEV CHEAT SHEET: Yocto / bitbake / devtool
Add anything useful you find, just try to keep it organized according to topic.  

## YOCTO LAYERS

## BITBAKE

### Reference Links
- [elinux Cheat Sheet](https://elinux.org/Bitbake_Cheat_Sheet)

### bitbake recipes (.bb & .bbappend files)

- `include` and `require` directives in recipes:  
BitBake uses the BBPATH variable to locate needed include and class files.  
The BBPATH variable is analogous to the environment variable PATH.  
Each layer typically adds itself to the BBPATH variable:  
`BBPATH .= ":${LAYERDIR}"`  
in the conf/layer.conf file. Thus paths relative to any layer will work. E.g. in our layer image recipe "hlio-image-rcd.bb" we include an ST provided .inc file:  
`include recipes-st/images/st-image.inc`  
__BBPATH is temporarily prepended to include the directory the recipe lives in, as a special case.__

### New bitbake topic here

## DEVTOOL
### Reference Links
- [Reference Manual](https://docs.yoctoproject.org/ref-manual/devtool-reference.html)
### Primary Commands
- `devtool modify <recipe-name>`
  - Will check out the source code into <tmp-dir>/workspace/sources
  - Allows modification and creation of patches
  - For examples, see [Add_Kernel_Driver.md](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/meta-hlio-rcd?path=/docs/Add_Kernel_Driver.md) and [Modify_Device_tree.md](https://dev.azure.com/HeliosEngineering/Right%20Cost%20Display/_git/meta-hlio-rcd?path=/docs/Modify_Device_Tree.md)
- `devtool build <recipe-name>`
  - Can also use bitbake, which will also grab changes from the working directory.
- `devtool finish <recipe-name> <path-to-layer>`
  - Creates patches based on *commits* in the working directory.
  - Updates the recipe
  - Resets the recipe to build normally rather than from the workspace
- `devtool reset <recipe-name>`
  - Remove the working directory settings, reverting builds to use the recipe
  - Does not remove the source directory, which is required for before future modifications
  - Use the `-r` or `--remove-work` to clean up the sources directory automatically

## New Category Here