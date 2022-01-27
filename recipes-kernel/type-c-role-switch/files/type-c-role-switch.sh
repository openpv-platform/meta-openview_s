set -e

command=$1
role_file_path="/sys/devices/platform/soc/49000000.usb-otg/usb_role/49000000.usb-otg-role-switch/role"
base_gpio_path="/sys/class/gpio"
cc_rd_en_pin="87"
cc_rp_en_pin="89"

help_diag() {
    echo "type-c-role-switch.sh <command>"
    echo "Change the role that the usb c is going to take."
    echo "    host    Act as a host to mass-storage drives, ethernet adapters, etc."
    echo "    device  Act as a device with a usb gadget emulating an ethernet connection, storage, etc."
    echo ""
}

if ! [ -f "$role_file_path" ]; then
    echo "Couldn't find \"$role_file_path\""
    echo "The role switching functionality isn't where we expect it to be."
    exit 1
fi

if ! [ -d "$base_gpio_path" ]; then
    echo "The gpio functionality isn't available through sysfs."
    exit 2
fi

if ! [ -d "$base_gpio_path/gpio$cc_rd_en_pin" ]; then
    echo "$cc_rd_en_pin" > "$base_gpio_path/export"
    if ! [ -d "$base_gpio_path/gpio$cc_rd_en_pin" ]; then
        echo "Couldn't get the sysfs directory for the gpio we wanted ($cc_rd_en_pin) exported."
        exit 3
    fi
    echo "out" > "$base_gpio_path/gpio$cc_rd_en_pin/direction"
fi

if ! [ -d "$base_gpio_path/gpio$cc_rp_en_pin" ]; then
    echo "$cc_rp_en_pin" > "$base_gpio_path/export"
    if ! [ -d "$base_gpio_path/gpio$cc_rp_en_pin" ]; then
        echo "Couldn't get the sysfs directory for the gpio we wanted ($cc_rp_en_pin) exported."
        exit 4
    fi
    echo "out" > "$base_gpio_path/gpio$cc_rp_en_pin/direction"
fi

case $command in
    "host") echo_value="host"; gpio_value="0" ;;
    "device") echo_value="none"; gpio_value="1" ;;
    *) echo "Unrecognized argument"; help_diag; exit ;;
esac

echo $echo_value > "$role_file_path"
new_role_value=$(cat "$role_file_path")

if [ "$new_role_value" = "$echo_value" ]; then
    echo "Successfully changed usb c role"
else
    echo "Unable to change the usb c role"
fi

echo "$gpio_value" > "$base_gpio_path/gpio$cc_rd_en_pin/value"
cc_rd_en_value=$(cat "$base_gpio_path/gpio$cc_rd_en_pin/value")
echo "$gpio_value" > "$base_gpio_path/gpio$cc_rp_en_pin/value"
cc_rp_en_value=$(cat "$base_gpio_path/gpio$cc_rp_en_pin/value")

if [ "$gpio_value" = "$cc_rd_en_value" ] && [ "$gpio_value" = "$cc_rp_en_value" ]; then
    echo "Successfully set the cc gpio pins"
else
    echo "Unable to change the cc gpio pins"
fi
