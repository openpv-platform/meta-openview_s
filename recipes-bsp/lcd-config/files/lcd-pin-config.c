#include <linux/gpio.h>
#include <sys/ioctl.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>

int probe_7in_select()
{
    struct gpiohandle_request req;
    struct gpiohandle_data data;
    int file, ret;

    // READ GPIOChip4 Line 1 -> PE1 on MCU

    req.lineoffsets[0] = 1;
    req.flags = GPIOHANDLE_REQUEST_INPUT;
    req.lines = 1;

    file = open("/dev/gpiochip4", 0);

    if ( file < 0 )
        return -1;

    ret = ioctl(file, GPIO_GET_LINEHANDLE_IOCTL, &req);
    if ( ret == -1 )
    {
        close(file);
        return -1;
    }

    if ( close(file) == -1 )
        return -1;

    ret = ioctl(req.fd, GPIOHANDLE_GET_LINE_VALUES_IOCTL, &data);
    if ( ret == -1 )
    {
        close(req.fd);
        return -1;
    }

    close(req.fd);

    // ioctl stores values that it reads in data.values array
    return data.values[0];
}

void set_UD_pin(int m)
{
    // U/D pin -> PC4 on mcu -> GPIO Chip 2, line 4 
    struct gpiohandle_request req;
    struct gpiohandle_data data;
    int file, ret;

    req.lineoffsets[0] = 4;
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    req.lines = 1;
    
    file = open("/dev/gpiochip2", 0);
    if ( file < 0 )
        return;
    
    ret = ioctl(file, GPIO_GET_LINEHANDLE_IOCTL, &req);
    if ( ret == -1 )
    {
        close(file);
        return;
    }

    data.values[0] = m;
    ret = ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    close(req.fd);
    printf("[] Done setting U/D pin [%i]...\n\r", m);
    return;
}

void set_LR_pin(int m)
{
    // L/R pin -> PA1 on mcu -> GPIO Chip 0, line 1 
    struct gpiohandle_request req;
    struct gpiohandle_data data;
    int file, ret;

    req.lineoffsets[0] = 1;
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    req.lines = 1;
    
    file = open("/dev/gpiochip0", 0);
    if ( file < 0 )
        return;
    
    ret = ioctl(file, GPIO_GET_LINEHANDLE_IOCTL, &req);
    if ( ret == -1 )
    {
        close(file);
        return;
    }

    data.values[0] = m;
    ret = ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    close(req.fd);
    printf("[] Done setting L/R pin [%i]...\n\r", m);
    return;
}



int main()
{

    int is7Inch = probe_7in_select();
    if (is7Inch)
    {
        // 7 inch needs U/D pin high and L/R pin low
        set_LR_pin(0);
        set_UD_pin(1);
        return 1;
    }

    // 5 inch needs both U/D pins low
    set_LR_pin(0);
    set_UD_pin(0);
    return 0;
}