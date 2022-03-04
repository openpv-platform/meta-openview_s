# strip out the st-demo packagegroup from core image extra install variable
PACKAGE_INSTALL := "${@oe.utils.str_filter_out('packagegroup-st-demo', '${CORE_IMAGE_EXTRA_INSTALL}', d)}"

# was to add our hlio-electron packagegroup to the user file system, no longer needed.
# Keep as a placekeeper if there are ever any packages that install files to the userfs
PACKAGE_INSTALL += " \
    "
