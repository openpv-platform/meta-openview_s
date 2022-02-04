#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "type-c-role-switch.h"

#define HOST_STRING                     "host"
#define PERIPHERAL_STRING               "device"

static void print_help_dialog() {
    printf("type-c-role-switch.sh <command>\n");
    printf("Change the role that the usb c is going to take.\n");
    printf("    host    Act as a host to mass-storage drives, ethernet adapters, etc.\n");
    printf("    device  Act as a device with a usb gadget emulating an ethernet connection, storage, etc.\n");
    printf("\n");
}

int main(int argc, char *argv[]) {
    #define IF_RET      \
        if (ret != 0) { \
            return ret; \
        }

    int ret = 0;

    if (argc == 1) {
        // If no arguments were provided, print out the help dialog
        print_help_dialog();
        return ret;
    }
    else if (argc != 2) {
        // If there was an incorrect number of arguments provided, note the error and then print the help dialog
        ret = -errno;
        perror("An insufficient number of arguments were provided.");
        print_help_dialog();
        return ret;
    }

    TYPE_C_ROLES_ENUM type_c_mode;
    if (strcmp(argv[1], HOST_STRING) == 0) {
        type_c_mode = TYPE_C_ROLES_HOST;
    }
    else if (strcmp(argv[1], PERIPHERAL_STRING) == 0) {
        type_c_mode = TYPE_C_ROLES_DEVICE;
    }
    else {
        ret = -errno;
        perror("An unrecognized usb role was requested");
        print_help_dialog();
        return ret;
    }

    ret = type_c_role_switch(type_c_mode);
    IF_RET;

    printf("Successfully changed the USB role. Now acting as a %s\n", argv[1]);
    return ret;
}