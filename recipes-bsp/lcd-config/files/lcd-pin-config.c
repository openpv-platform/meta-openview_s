#include <linux/gpio.h>
#include <sys/ioctl.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define VERSION_VOLTAGE_TOLERANCE 0.060
#define RCD_H1000301 0.0
#define RCD_H1000302 3.3

#define ID_VOLTAGE_TOLERANCE 0.145
#define LCD_5IN_VOLTAGE 0.0
#define LCD_7IN_VOLTAGE 3.3
#define LCD_10IN_VOLTAGE 2.82

#define ADC_AVERAGE_COUNT 100
#define BUFFER_SIZE 6
#define VERSION_VOLTAGE_RAW "/sys/devices/platform/soc/48003000.adc/48003000.adc:adc@0/iio:device0/in_voltage5_raw"
#define LCD_ID_VOLTAGE_RAW "/sys/devices/platform/soc/48003000.adc/48003000.adc:adc@0/iio:device0/in_voltage7_raw"

#define ADC_SCALE (3.3/65535.0)

double read_adc(const char* path)
{
    // Read the voltage
    FILE *fptr;
    fptr = fopen(path, "r");
    if (fptr == NULL)
    {
        printf("lcd-pin-config: failure to open device: %s\r\n", path);
        return -1.0;
    }

    char voltage_raw[BUFFER_SIZE]; // 16 bits, maximum of 5 digits + \0
    memset (voltage_raw, 0, BUFFER_SIZE);
    fgets(voltage_raw, BUFFER_SIZE, fptr);
    fclose(fptr);

    // Convert the string to digits
    char *ptr;
    long i = strtol(voltage_raw, &ptr, 10);
    return i * ADC_SCALE;
}

double read_adc_avg(const char* path)
{
    double avg_adc_value = 0;
    for (int i = 0; i < ADC_AVERAGE_COUNT; i++)
    {
        avg_adc_value += read_adc(path);
    }

    return (avg_adc_value / (double)ADC_AVERAGE_COUNT);
}

double probe_version_voltage()
{
    // Set the GPIOChip4 7 and 10 to 0
    struct gpiohandle_request req;
    struct gpiohandle_data data;
    int file, ret;
    double version_voltage;

    req.lineoffsets[0] = 7;
    req.lineoffsets[0] = 10;
    data.values[0] = 0; // LOW offset 7
    data.values[1] = 0; // LOW offset 10
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    req.lines = 2;

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

    ret = ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    if ( ret == -1 )
    {
        close(req.fd);
        return -1;
    }

    close(req.fd);

    // Set the GPIOChip5 8 to 0
    req.lineoffsets[0] = 8;
    data.values[0] = 0; // LOW offset 8
    req.flags = GPIOHANDLE_REQUEST_OUTPUT;
    req.lines = 1;

    file = open("/dev/gpiochip5", 0);

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

    ret = ioctl(req.fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data);
    if ( ret == -1 )
    {
        close(req.fd);
        return -1;
    }

    close(req.fd);

    version_voltage = read_adc_avg(VERSION_VOLTAGE_RAW);
    if (version_voltage < 0.0)
    {
        printf("lcd-pin-config: Error reading version_voltage. Returning 0 version voltage.\r\n");
        return 0;
    }

    printf("lcd-pin-config: version_voltage: %f\r\n", version_voltage);
    return version_voltage;
}

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
    // If this board is not newer hardware use GPIOChip4 Line 1
    double version_voltage = probe_version_voltage();
    if (fabs (version_voltage - RCD_H1000301) < VERSION_VOLTAGE_TOLERANCE ||
        fabs (version_voltage - RCD_H1000302) < VERSION_VOLTAGE_TOLERANCE )
    {
        int is7Inch = probe_7in_select();
        if (is7Inch)
        {
            printf("[] 7 inch LCD detected...\n\r");
            // 7 inch needs U/D pin high and L/R pin low
            set_LR_pin(0);
            set_UD_pin(1);
            return 1;
        }

        printf("[] 5 inch LCD detected...\n\r");
        // 5 inch needs both U/D pins low
        set_LR_pin(0);
        set_UD_pin(0);
        return 0;
    }
    else
    {
        double ldc_id_voltage = read_adc_avg(LCD_ID_VOLTAGE_RAW);
        if (ldc_id_voltage < 0.0)
        {
            printf("lcd-pin-config: Error reading ldc_id_voltage. Skipping configuration.\r\n");
            return 0;
        }

        printf("lcd-pin-config: ldc_id_voltage: %f\n\r", ldc_id_voltage);
        if (fabs(ldc_id_voltage - LCD_10IN_VOLTAGE) < ID_VOLTAGE_TOLERANCE)
        {
            printf("[] 10 inch LCD detected...\n\r");
            // 10 inch does not have U/D or L/R pins
            return 2;
        }
        else if (fabs(ldc_id_voltage - LCD_7IN_VOLTAGE) < ID_VOLTAGE_TOLERANCE)
        {
            printf("[] 7 inch LCD detected...\n\r");
            // 7 inch needs U/D pin high and L/R pin low
            set_LR_pin(0);
            set_UD_pin(1);
            return 1;
        }
        else // Default to 5 inch
        {
            printf("[] 5 inch LCD detected...\n\r");
            // 5 inch needs both U/D pins low
            set_LR_pin(0);
            set_UD_pin(0);
            return 0;
        }
    }
}