

# strip out the st-demo packagegroup from core image extra install variable
CORE_IMAGE_EXTRA_INSTALL := "${@oe.utils.str_filter_out('packagegroup-st-demo', '${CORE_IMAGE_EXTRA_INSTALL}', d)}"


# add any new packages if desired
CORE_IMAGE_EXTRA_INSTALL += "\
    "