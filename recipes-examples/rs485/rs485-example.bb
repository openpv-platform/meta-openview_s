# NOTE: LICENSE is being set to "CLOSED" to allow you to at least start building - if
# this is not accurate with respect to the licensing of the software being built (it
# will not be in most cases) you must specify the correct value before using this
# recipe for anything other than initial testing/development!
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

# FILESEXTRAPATHS_prepend := "${THISDIR}/:"

# No information for SRC_URI yet (only an external source tree was specified)
SRC_URI = "file://rs485-example.c"

S = "${WORKDIR}"

do_configure () {
	# Specify any needed configure commands here
	:
}

do_compile () {
	# Specify compilation commands here
	${CC} rs485-example.c -o rs485-example
}

do_install () {
	# Specify install commands here
	install -d ${D}${bindir}
	install -m 755 rs485-example ${D}${bindir}
	# This copy was for debugging purposes to preserve the binary for easy transfer to target. Kept for future reference.
	# cp rs485-example temp
}

RM_WORK_EXCLUDE_ITEMS += "rs485-example"