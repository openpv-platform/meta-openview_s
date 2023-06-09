# Change the Files path for the procps directory with the one that is in our repository.
# NOTE: BMG (Mar. 02, 2022) This line here is going to prepend the files path to the list of possible locations for the
#  file the recipe is looking for. What that is going to do for us is ensure that our file is used over any of the files
#  that are in the original recipe, allowing us to add the file without having to copy the recipe and while also
#  ensuring that the file is processed by all the same functions. It's basically a way of adding to a recipe without
#  changing it.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://0001-Merging-in-changes-from-Freescale-to-driver-6-4-7.patch \
    file://0002-Added-a-function-that-was-missing-6-4-7.patch \
    "
