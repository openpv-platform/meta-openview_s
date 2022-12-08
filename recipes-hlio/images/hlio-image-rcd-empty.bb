# SUMMARY = "Helios empty image"
# LICENSE = "MIT"
# 
# include recipes-st/images/st-image-partitions.inc
# 
# # Add specific package for our image:
# PACKAGE_INSTALL += ""
# 
# # Add specific initrd package to bootfs
# INITRD_PACKAGE ?= ""
# PACKAGE_INSTALL += ""

SUMMARY = "An empty image."
IMAGE_INSTALL = ""
IMAGE_LINGUAS = ""
PACKAGE_INSTALL = ""

inherit image
