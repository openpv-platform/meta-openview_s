#!/bin/sh

#add stm32_eth_config script to enable USB Ethernet & MSC gadget This script configures USB Gadget
#configfs to use USB OTG as a USB Ethernet Gadget with Remote NDIS (RNDIS), well supported by Microsoft
#Windows and Linux.

configfs="/sys/kernel/config/usb_gadget"
g=g1
c=c.1
e=c.2
d="${configfs}/${g}"
func_eth=rndis.0
func_ecm=ecm.1
func_ms=mass_storage.0

VENDOR_ID="0x1d6b"
PRODUCT_ID="0x0104"

get_mac_address_from_serial_number(){
    sha1sum /proc/device-tree/serial-number \
    | fold -1 \
    | sed -n '1{h;d};2{y/1235679abdef/000444888ccc/;H;d};13{g;s/\n//g;p;q};s/^/:/;N;H;d'
}

do_start() {
    if [ ! -d ${configfs} ]; then
        modprobe libcomposite
        if [ ! -d ${configfs} ]; then
        exit 1
        fi
    fi

    if [ -d ${d} ]; then
        exit 0
    fi

    udc=$(ls -1 /sys/class/udc/)
    if [ -z $udc ]; then
        echo "No UDC driver registered"
        exit 1
    fi

    mkdir "${d}"
    echo ${VENDOR_ID} > "${d}/idVendor"
    echo ${PRODUCT_ID} > "${d}/idProduct"
    echo 0x0200 > "${d}/bcdUSB"
    echo "0xEF" > "${d}/bDeviceClass"
    echo "0x02" > "${d}/bDeviceSubClass"
    echo "0x01" > "${d}/bDeviceProtocol"
    echo "0x0100" > "${d}/bcdDevice"

    mkdir -p "${d}/strings/0x409"
    tr -d '\0' < /proc/device-tree/serial-number > "${d}/strings/0x409/serialnumber"
    echo "Enovation Controls" > "${d}/strings/0x409/manufacturer"
    echo "OpenView" > "${d}/strings/0x409/product"

    # Config RNDIS
    mkdir -p "${d}/configs/${c}"
    mkdir -p "${d}/configs/${c}/strings/0x409"
    echo "Config 1: RNDIS" > "${d}/configs/${c}/strings/0x409/configuration"
    echo 0 > "${d}/configs/${c}/MaxPower"
    echo 0xC0 > "${d}/configs/${c}/bmAttributes" # self powered device

    # Config EEM
    mkdir -p "${d}/configs/${e}"
    mkdir -p "${d}/configs/${e}/strings/0x409"
    echo "Config 2: ECM" > "${d}/configs/${e}/strings/0x409/configuration"
    echo 0 > "${d}/configs/${e}/MaxPower"
    echo 0xC0 > "${d}/configs/${e}/bmAttributes" # self powered device

    # Windows extension to force RNDIS config
    mkdir -p "${d}/os_desc"
    echo "1" > "${d}/os_desc/use"
    echo "0xbc" > "${d}/os_desc/b_vendor_code"
    echo "MSFT100" > "${d}/os_desc/qw_sign"

    mkdir -p "${d}/functions/${func_eth}"
    mkdir -p "${d}/functions/${func_eth}/os_desc/interface.rndis"
    echo "RNDIS" > "${d}/functions/${func_eth}/os_desc/interface.rndis/compatible_id"
    echo "5162001" > "${d}/functions/${func_eth}/os_desc/interface.rndis/sub_compatible_id"

    # Set mac address
    mac_host=$(get_mac_address_from_serial_number)
    echo $mac_host > "${d}/functions/${func_eth}/host_addr"

    # Set up the rndis device only first
    ln -s "${d}/functions/${func_eth}" "${d}/configs/${c}"
    ln -s "${d}/configs/${c}" "${d}/os_desc"

    # Set up the ecm device
    mkdir -p "${d}/functions/${func_ecm}"
    ln -s "${d}/functions/${func_ecm}" "${d}/configs/${e}"

    echo "${udc}" > "${d}/UDC"

    sleep 0.2

    # Bring up rndis device
    ifconfig usb0 up

    # Bring up ecm device
    ifconfig usb1 up
}

do_stop() {
    interfacename=$(cat ${d}/functions/${func_eth}/ifname 2> /dev/null)
    if [ -z "${interfacename}" ];
    then
        echo "Nothing to do for rndis device"
        return
    fi
    ifconfig ${interfacename} down

    interfacename=$(cat ${d}/functions/${func_ecm}/ifname 2> /dev/null)
    if [ -z "${interfacename}" ];
    then
        echo "Nothing to do for ecm device"
        return
    fi
    ifconfig ${interfacename} down

    sleep 0.2

    echo "" > "${d}/UDC"

    rm -f "${d}/os_desc/${c}"
    [ -d "${d}/configs/${c}/${func_eth}" ] &&rm -f "${d}/configs/${c}/${func_eth}"

    [ -d "${d}/strings/0x409/" ] && rmdir "${d}/strings/0x409/"
    [ -d "${d}/configs/${c}/strings/0x409" ] && rmdir "${d}/configs/${c}/strings/0x409"
    [ -d "${d}/configs/${c}" ] && rmdir "${d}/configs/${c}"
    [ -d "${d}/functions/${func_eth}" ] && rmdir "${d}/functions/${func_eth}"
    [ -d "${d}" ] && rmdir "${d}"
}

case $1 in
    start)
        echo "Start usb gadget"
        do_start
        ;;
    stop)
        echo "Stop usb gadget"
        do_stop
        ;;
    restart)
        echo "Stop usb gadget"
        do_stop
        sleep 1
        echo "Start usb gadget"
        do_start
        ;;
    *)
        echo "Usage: $0 (stop | start | restart)"
        ;;
esac
