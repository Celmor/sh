#!/bin/bash
set -e
echo "$1"
test -f "/sys/bus/pci/devices/0000:$1/driver_override"
drivers=("/sys/bus/pci/devices/0000\:$1/driver/module/drivers/pci:"*)
test ${#drivers[@]} -gt 0
driver="${drivers[0]##*:}"
test -f "/sys/bus/pci/drivers/$driver/bind"
printf "driver: %s\n" "$driver"
read -p confirm?
echo "0000:$1" > /sys/bus/pci/drivers/vfio-pci/unbind
echo "$driver" > "/sys/bus/pci/devices/0000:$1/driver_override"
echo "0000:$1" > "/sys/bus/pci/drivers/$driver/bind"
