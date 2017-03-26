#!/bin/bash
# Ver. 3.4, 2016-08-31, by Celmor
# File: ~celmor/qemu/qemu.sh
set -e

QemuImage=/dev/zvol/VM/Win10Qemu
GameDisk=/dev/zvol/VM/Games
FatSharePath=/Data/Backup/Disk/VM/share/
pagefile=/dev/zvol/VM/pagefile
#QEMU_AUDIO_DRV=pa
QEMU_ALSA_DAC_BUFFER_SIZE=512 QEMU_ALSA_DAC_PERIOD_SIZE=170 QEMU_AUDIO_DRV=alsa PA_LATENCY_MSEC=100

pidfile=qemu_setup.pid
[ `whoami` = root ] || exec sudo su -c "$0 $@" root
if [ ! -f "/tmp/$pidfile" ]; then
	ip link add name br0 type bridge
	ip addr add 10.0.1.1/24 dev br0
	ip link set br0 up
	ip tuntap add dev tap0 mode tap
	ip link set tap0 master br0
	ip link set tap0 up promisc on
	echo $$ > $pidfile
	fi

if [ "$1" = "-h" -o "$1" = "--help" ]; then
cat << EOF
Usage: $0 [-h] [-nonet] [-minimal]"
Custom Qemu configuration and start script."

  -h, --help   Display this help"
  -nonet       Provide no virtual network adapter to guest"
  -minimal     No pass-through of Gamepad, Corsair Link, Game Partition or Sound"
  -cdrom       Provide virtio Driver and Windows ISO (only acceptable as 3rd parameter)"
EOF
exit 0
fi
if [ "$1" = "-nonet" -o "$2" = "-nonet" ]; then
  net='none'; else
  net="nic -net tap,ifname=tap0,script=no,downscript=no"
  fi
if [ "$1" != "-minimal" -a "$2" != "-minimal" ]; then
  Gamepad="-usbdevice host:28de:1142"
  Corsair_Link="-usbdevice host:1b1c:0c04"
  Sound="-soundhw hda"
  Games="-drive file=$GameDisk,format=raw,cache=writeback,media=disk"
  fi
if [ "$2" == "-fatshare" ]; then
  FatShare="-drive file=fat:rw:$FatSharePath,format=raw,cache=none"
  fi
if [ "$3" == "-cdrom" ]; then
  Driver="-drive file=$VM/tools/virtio-win-0.1.118.iso,media=cdrom"
  WinIso="-drive file=$VM/tools/win10.iso,media=cdrom"
  fi

#echo 1 > /proc/sys/vm/overcommit_memory && \
sync && echo 3 > /proc/sys/vm/drop_caches && \
cp /usr/share/edk2.git/ovmf-x64/OVMF_VARS-pure-efi.fd /tmp/my_vars.fd && \
qemu-system-x86_64 \
  -name debug-threads=on `# to see vcpu threads` \
  -enable-kvm \
  -m $((10*1024)) \
  -cpu host,kvm=off -smp maxcpus=6,sockets=1,cores=3,threads=2 \
  -drive if=pflash,format=raw,readonly,file=/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd \
  -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
  `# Features` \
        -rtc base=localtime \
        -net $net \
	    ${Sound+$Sound} \
  `# Peripheral_devices` \
    `# G910:`           -usbdevice host:046d:c32b \
    `# Gamepad:`        ${Gamepad+$Gamepad} \
    `# Corsair_Link`    ${Corsair_Link+$Corsair_Link} \
    `# Nvidia_GPU:`     -device vfio-pci,host=01:00.1 \
    `# Nvidia_Audio:`   -device vfio-pci,host=01:00.0,multifunction=on \
                        -vga none \
  `# Disks` \
    `# Windows:`        -drive file=$QemuImage,format=raw,cache=writeback,media=disk \
    `# pagefile:`       -drive file=$pagefile,format=raw,cache=unsafe,media=disk \
    `# Games:`          ${Games+$Games} \
    `# Driver:`         ${Driver+$Driver} \
    `# WinIso:`         ${WinIso+$WinIso} \
    `# FatShare:`       ${FatShare+$FatShare}

exit 0

: << 'used_devices'
lspci:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GM200 [GeForce GTX 980 Ti] [10de:17c8] (rev a1)
    Subsystem: Gigabyte Technology Co., Ltd Device [1458:36cf]
    Kernel driver in use: vfio-pci
    Kernel modules: nouveau
01:00.1 Audio device [0403]: NVIDIA Corporation GM200 High Definition Audio [10de:0fb0] (rev a1)
    Subsystem: Gigabyte Technology Co., Ltd Device [1458:36cf]
    Kernel driver in use: vfio-pci
    Kernel modules: snd_hda_intel
lsusb:
Bus 001 Device 006: ID 046d:c07d Logitech, Inc.
    # G502
Bus 001 Device 004: ID 28de:1142
    # Steam Controller
Bus 001 Device 008: ID 041e:3237 Creative Technology, Ltd
    # Sound Blaster X-Fi
Bus 001 Device 007: ID 046d:c32b Logitech, Inc.
    # G910
Bus 001 Device 010: ID 1b1c:0c04 Corsair
    # Corsair H100i
used_devices
