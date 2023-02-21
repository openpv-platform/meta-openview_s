#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <stdint.h>

// #include <linux/gpio.h>
// #include <gpiod.h>
#include "gpiod.h"
// #include <linux/gpio/consumer.h>

#include "can-standby-enable-lib.h"

#define GPIO_CHIP_INDEX  0
#define GPIO_DEV    "gpiochip"

#define CAN_STANDBY_EN_PIN 13

static int open_gpiod_chip(struct gpiod_chip **gpio_chip, int gpiochip_index) {
    char gpio_dev_name[20];
    int ret = 0;

    // Store the name of the gpio device in the chr
    sprintf(gpio_dev_name, "%s%d", GPIO_DEV, gpiochip_index);

    // Open the file descriptor for the device
    *gpio_chip = gpiod_chip_open_by_name(gpio_dev_name);
    if (!*gpio_chip) {
        // If the file descriptor wasn't successfully able to be opened, return an error
        ret = -errno;
        fprintf(stderr, "Failed to open the gpiod chip: %s\n", gpio_dev_name);
    }

    return ret;
}

static int open_gpiod_line(struct gpiod_chip *gpio_chip, struct gpiod_line **gpio_line, int pin_index) {
    int ret = 0;

    *gpio_line = gpiod_chip_get_line(gpio_chip, pin_index);
    gpiod_line_request_output(*gpio_line, "can-standby-enable-bin", 0);
    if (!*gpio_line) {
        // If the file descriptor wasn't successfully able to be opened, return an error
        ret = -errno;
        fprintf(stderr, "Failed to issue get gpiod chip line (%d)\n", ret);
    }

    return ret;
}

static int close_gpiod_chip(struct gpiod_chip *gpio_chip) {
    int ret = 0;

    gpiod_chip_close(gpio_chip);

    return ret;
}

static int close_gpiod_line(struct gpiod_line *gpio_line) {
    int ret = 0;

    gpiod_line_release(gpio_line);

    return ret;
}

static int set_pin_value(struct gpiod_line *gpio_line, uint8_t value) {
    int ret = 0;

    ret = gpiod_line_set_value(gpio_line, value);
    if (ret < 0) {
        // If the file descriptor wasn't successfully able to be opened, return an error
        ret = -errno;
        fprintf(stderr, "Failed to request the output that was passed to the set_pin_value function (%d)\n", ret);
    }

    return ret;
}

#define CLOSE_GPIOD \
    if (!gpiod_chip) {                  \
        gpiod_chip = NULL;              \
        close_gpiod_chip(gpiod_chip);   \
    }                                   \
    if (!gpiod_line) {                  \
        gpiod_line = NULL;              \
        close_gpiod_line(gpiod_line);   \
    }

#define IF_RET          \
    if (ret != 0) {     \
        CLOSE_GPIOD     \
        return ret;     \
    }

int can_standby_enable(CAN_STANDBY_ENABLE_ENUM can_standby_enable) {
    int ret = 0;

    uint8_t gpio_set_value;
    switch (can_standby_enable) {
    case CAN_STANDBY_ENABLE_TRUE:
        gpio_set_value = 1;
        break;
    case CAN_STANDBY_ENABLE_FALSE:
        gpio_set_value = 0;
        break;
    default:
        ret = -errno;
        perror("An unrecognized usb role was requested");
        return ret;
    }

    //////////////////////////////////////////////////
    // GPIO setup
    //////////////////////////////////////////////////
    // struct gpiohandle_request req_can_stby;
    // struct gpiohandle_data data_can_stby;
    struct gpiod_chip *gpiod_chip = NULL;
    struct gpiod_line *gpiod_line = NULL;

    // Open the file descript for the gpiochip that contains the two pins that we are going to be modifying
    ret = open_gpiod_chip(&gpiod_chip, GPIO_CHIP_INDEX);
    IF_RET;

    // open up the linehandles for the two pins that we are going to want to modify
    ret = open_gpiod_line(gpiod_chip, &gpiod_line, CAN_STANDBY_EN_PIN);
    IF_RET;

    ret = set_pin_value(gpiod_line, gpio_set_value);
    IF_RET;

    //////////////////////////////////////////////////
    // cleanup
    //////////////////////////////////////////////////
    // close the linehandles for the two pins that we were modifying
    CLOSE_GPIOD;
    IF_RET;

    return ret;
}
