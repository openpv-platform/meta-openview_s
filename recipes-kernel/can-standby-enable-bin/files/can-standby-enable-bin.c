#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "can-standby-enable-lib.h"

#define TRUE_STRING     "true"
#define FALSE_STRING    "false"

static void print_help_dialog() {
    printf("can-standby-enable-bin <command>\n");
    printf("Enable or disable the CAN transceivers on the unit.\n");
    printf("    true    Puts the CAN transceivers on the unit into it's standby mode.\n");
    printf("    false   Puts the CAN transceivers on the unit into it's enabled mode.\n");
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

    CAN_STANDBY_ENABLE_ENUM can_standby_en;
    char can_stby_state_string[9];
    if (strcmp(argv[1], TRUE_STRING) == 0) {
        can_standby_en = CAN_STANDBY_ENABLE_TRUE;
        strncpy(can_stby_state_string, "enabled", 8);
    }
    else if (strcmp(argv[1], FALSE_STRING) == 0) {
        can_standby_en = CAN_STANDBY_ENABLE_FALSE;
        strncpy(can_stby_state_string, "disabled", 9);
    }
    else {
        ret = -errno;
        perror("An unrecognized CAN standby state was requested");
        print_help_dialog();
        return ret;
    }

    ret = can_standby_enable(can_standby_en);
    IF_RET;

    printf("Successfully changed the CAN standby enable state. CAN standby is now %s\n", can_stby_state_string);
    printf("\n");
    return ret;
}