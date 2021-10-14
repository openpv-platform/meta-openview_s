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

## New Category Here