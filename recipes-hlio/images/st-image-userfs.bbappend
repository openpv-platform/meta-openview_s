# strip out the st-demo packagegroup from core image extra install variable
PACKAGE_INSTALL := "${@oe.utils.str_filter_out('packagegroup-st-demo', '${CORE_IMAGE_EXTRA_INSTALL}', d)}"

# add our hlio-webkit packagegroup to the user file system
# PACKAGE_INSTALL += " \
#     packagegroup-hlio-webkit \
#     "
