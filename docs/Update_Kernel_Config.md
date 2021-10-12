# Update Kernel Configuration

This documentation is meant to provide a guide to a new developer with details on how to update the configuration used
when building the kernel in case some feature needs to be added/removed for certain builds. Generally, this guide will
take you through the process of:

1. Bringing up the user interface to select which features are going to be included in the kernel that is built.
2. Saving that configuration somewhere.
3. Using bitbake to create the new kernel fragment to apply the changes that were made to the kernel configuration.
4. Rebuilding using bitbake and the new changes that were made to the default kernel for the device.

## Changing the configuration for the kernel

In order to change the configuration of the kernel for your build you need to make sure you run all of these commands
with an environment that's setup. i.e. If you're at the point where you're ready to run the `bitbake hlio-image-rcd`,
you can run the following commands to go through the kernel configuration.

In order to run the menuconfig command for the kernel we are working with you would have to run the
`bitbake linux-stm32mp -c menuconfig`. This would bring up a text-based menu to go through the configuration of the
kernel. This will give you options for just about everything that is supported by the linux kernel. For example, if you
want to change some of the configurations associated with CAN, go into the
`Networking support->CAN bus subsystem support` to access all the settings related to the CAN functionality of the linux
kernel.

Once you go through the menu and make all the changes that you're interested in making you can go in and select the
`<save>` menu option. Bitbake can actually provide the contents of the fragment by running the
`bitbake linux-stm32mp -c diffconfig` command. This command NEEDS to be run right after the menuconfig instance that
made changes to the kernel configuration, if the menuconfig is run again and more changes are made the first set of
changes wouldn't be detected by the diffconfig command. The file that would be output is then place in the
`<BUILD_DIR>/tmp-glibc/work/stm32mp1-ostl-linux-gnueabi/linux-stm32mp/5.10.10-r0/` directory under the name
`fragment.cfg`, this file can then be copied into the `recipes-kernel/linux/linux-stm32mp/fragments/` directory and add
it to the `linux-stm32mp_%.bbappend` file in this repository in a similar way to how the `fragment_01_enable_j1939.cfg`
was added previously.

Once that new fragment has been added to this repository you can run the `bitbake hlio-image-rcd` command to compile the
image again.
