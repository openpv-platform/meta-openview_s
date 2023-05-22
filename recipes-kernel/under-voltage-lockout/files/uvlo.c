/******************************************************************************
 *
 * @file   uvlo.c
 * @author HCEE Software Team
 * @date   November 2022
 * @brief  Simple kernel module for handling the board shutdown when the
 *		   Under Voltage Lockout circuit input goes high. 
 *
******************************************************************************/

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h>
#include <linux/interrupt.h>
#include <linux/kmod.h>
#include <linux/delay.h>
#include <linux/unistd.h>
#include <linux/workqueue.h>

// constants
const unsigned int uvlo_pin = 2; // PA2 on our micro

// globals
unsigned int irq_num;
unsigned int trigger_once = 1;

// declare a few function signatures
static irq_handler_t uvlo_ISR(unsigned int irq, void *dev_id, struct pt_regs *regs);
static struct work_struct initiate_reboot_work;

static void initiate_reboot(struct work_struct *work) {
	int ret;
	char *argv[] = { "/bin/systemctl",
	                "reboot",
					NULL 
	};
  	char *envp[] = {
        "HOME=/",
        "PATH=/sbin:/bin:/usr/sbin:/usr/bin",
		NULL 
	};

	// Should we check for gpio low to ignore jitter?

	printk(KERN_INFO "uvlo: rebooting system...\n");
	ret = call_usermodehelper( argv[0], argv, envp, UMH_WAIT_EXEC );
	printk(KERN_INFO "uvlo: return from usermodehelper: [%d]\n", ret);
}

// init function
static int __init uvlo_init(void)
{
	// init the kernel module

	INIT_WORK(&initiate_reboot_work, initiate_reboot);

	int result = 0;
	if (!gpio_is_valid(uvlo_pin))
	{
		printk(KERN_INFO "uvlo: Incorrect GPIO Pin used for the UVLO circuit!\n");
		return -1;
	}

	// set the uvlo pin as gpio and init it's sysfs interface
	gpio_request(uvlo_pin, "sysfs");
	
	// configure as input
	gpio_direction_input(uvlo_pin);

	// export to /sys/class/gpio
	gpio_export(uvlo_pin, false);

	// Perform a quick test to see that the pin is working as expected on LKM load
	printk(KERN_INFO "uvlo: The uvlo pin is currently: %d\n", gpio_get_value(uvlo_pin));

	// map the uvlo gpio number to the systems IRQ number
	irq_num = gpio_to_irq(uvlo_pin);
	// printk(KERN_INFO "KMOD_TEST: The uvlo pin is mapped to IRQ: %d\n", irq_num);

	// request an interrupt line
	result = request_irq(irq_num,             		// Interrupt number requested
						 (irq_handler_t) uvlo_ISR, 	// Pointer to the handler function below
						 IRQF_TRIGGER_RISING,   	// Interrupt on rising edge 
						 "uvlo-kmod",    			// Used in /proc/interrupts to identify the owner
						 NULL);                 	// The *dev_id for shared interrupt lines, NULL is okay

	printk(KERN_INFO "uvlo: Successfully initialized the UVLO Kernel Module: result = [%d]\n", result);
	return 0;
}


static irq_handler_t uvlo_ISR(unsigned int irq, void *dev_id, struct pt_regs *regs)
{
	int result;
	struct subprocess_info* sub_info;

	if (trigger_once)
	{
		// run the rebooot command
		printk(KERN_INFO "uvlo: UVLO triggered...\n");
		schedule_work(&initiate_reboot_work);
		trigger_once = 0;
	}

    return (irq_handler_t) IRQ_HANDLED;      // Announce that the IRQ has been handled correctly
}


static void __exit uvlo_exit(void){
	free_irq(irq_num, NULL);               // Free the IRQ number, no *dev_id required in this case
	gpio_unexport(uvlo_pin);               // Unexport the uvlo GPIO
	gpio_free(uvlo_pin);                   // Free the uvlo GPIO
	printk(KERN_INFO "Exiting UVLO Kernel Mod...\n");
}


module_init(uvlo_init);
module_exit(uvlo_exit);


MODULE_LICENSE("GPL");
MODULE_AUTHOR("HCEE");
MODULE_DESCRIPTION("Custom RCD uvlo module");
MODULE_VERSION("0.1");