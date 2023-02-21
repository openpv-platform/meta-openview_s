#!/bin/sh

if [[ $# != 1 ]]; then 
	echo "Expected 1 argument for the version:"
	echo "   $0 0.4"
	exit -1
fi
WANTED_FIRMWARE=$1

function update_firmware()
{
	ESP_DIR=/lib/esp32

	python3 ${ESP_DIR}/tools/esptool.py -p /dev/ttySTM2 -b 960000 --before default_reset --after hard_reset \
		write_flash --flash_mode dio --flash_freq 40m --flash_size detect \
		0x1000 ${ESP_DIR}/firmware/esp_hosted_bootloader_esp32_sdio.bin \
		0x8000 ${ESP_DIR}/firmware/esp_hosted_partition-table_esp32_sdio.bin \
		0xd000 ${ESP_DIR}/firmware/esp_hosted_ota_data_initial.bin \
		0x10000 ${ESP_DIR}/firmware/esp_hosted_firmware_esp32_sdio.bin
}

function power_off() {
	# Listen to serial during boot until we see the firmware version::: ESP-Hosted Firmware version :: 0.3
	gpioset gpiochip2 15=0
	usleep 10
}

function power_on() {
	# IO12 (MTDI) Low = 3.3V flash
	gpioset gpiochip3 5=0
	usleep 10
	gpioset gpiochip2 15=1
}

function force_sdio_card_detect() {

	# This will force a manual card detect to effectively detect the driver/device since we have no CD pin                             
        echo 1 > /sys/devices/platform/soc/48004000.mmc/manual_detect_card_change 
}

function get_firmware_version() {
	power_off

	REGEX='ESP-Hosted(-FG)? Firmware version :: ([0-9]+\.[0-9]+\.?[0-9]+?)'

	# Set baud to 115200, then start listening, then enable power, then search for string for up to 3 seconds.  Else assume no firmware
	stty -F /dev/ttySTM2 raw -echo -echoe -echok 115200

	power_on
	(timeout 2s cat /dev/ttySTM2) | while read LOGLINE
	do
		# Enable this line to enable output for debug
		# DOESNT WORK WITHIN A FUNCTION echo ${LOGLINE}

		# Search for the version string, and using regexp groups, make sure it matches what we expect
		MATCH=$(echo "${LOGLINE}" | sed -nr "s/.*${REGEX}.*/\2/p")
		if [ "$MATCH" != "" ]; then
			pkill -P $$ cat

			#Found version in ${BASH_REMATCH[1]}
			echo "${MATCH}"
			return
		fi
	done
	echo ""
	return
}

echo "Modprobing esp32_sdio..." # Do this early since we're waiting on ESP32 to boot anyway
modprobe esp32_sdio

echo "Rebooting ESP32 and listening for firmware version $WANTED_FIRMWARE..."
FIRMWARE_VERSION=$(get_firmware_version)

echo "Detected Firmware = ${FIRMWARE_VERSION}"

if [[ "$FIRMWARE_VERSION" != "$WANTED_FIRMWARE" ]]; then
	echo "Found wrong version. Got $FIRMWARE_VERSION. Wanted $WANTED_FIRMWARE. Will update firmware now..."
	update_firmware
	
	#NOTE: It seems that after a second run the GPIOD is reserved by the python programming script and kernel driver fails. So something
	# in esptool.py may not be releasing the pins properly, or else we need to figure a manual way to do it to make sure the kernel can
	# re-aquire them when it comes out of "sleep"

else
	echo "Found matching version $WANTED_FIRMWARE..."
fi

# Restart the module. Timing is important here. The esp32 firmware initiates sdio comms 1 second after initialization.
power_off
power_on
sleep 1
force_sdio_card_detect

echo "ESP32 should be detected now"


                                                                                    
