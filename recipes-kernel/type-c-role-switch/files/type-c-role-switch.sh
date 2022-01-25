set -e

command=$1
role_file_path="/sys/devices/platform/soc/49000000.usb-otg/usb_role/49000000.usb-otg-role-switch/role"

help_diag() {
    echo "type-c-role-switch.sh <command>"
    echo "Change the role that the usb c is going to take."
    echo "    host    Act as a host to mass-storage drives, ethernet adapters, etc."
    echo "    device  Act as a device with a usb gadget emulating an ethernet connection, storage, etc."
    echo ""
}

case $command in
    "host") echo_value="host" ;;
    "device") echo_value="none" ;;
    *) echo "Unrecognized argument"; help_diag; exit ;;
esac

echo $echo_value > "$role_file_path"
new_role_value=$(cat "$role_file_path")

if [ "$new_role_value" = "$echo_value" ]; then
    echo "Successfully changed usb c role"
else
    echo "Unable to change the usb c role"
fi
