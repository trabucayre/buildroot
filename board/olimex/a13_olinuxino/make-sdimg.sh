#! /bin/sh

IMAGES_DIR=$1
SPL_IMG=$IMAGES_DIR/u-boot-sunxi-with-spl.bin
FDT_IMG=$IMAGES_DIR/sun5i-a13-olinuxino-micro.dtb
UIMAGE=$IMAGES_DIR/uImage
BIN_BOARD_FILE=$IMAGES_DIR/script.bin
ROOTFS=$IMAGES_DIR/rootfs.tar
BOOT_CMD_H=$IMAGES_DIR/boot.scr

export LC_ALL=C

if [ $# -ne 2 ]; then
	echo "Usage: $0 <images_dir> <drive>"
	exit 1;
fi

if [ `id -u` -ne 0 ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

DRIVE=$2
P1=`mktemp -d`
P2=`mktemp -d`

dd if=/dev/zero of=$DRIVE bs=1M count=3

SIZE=`fdisk -l $DRIVE | grep Disk | grep bytes | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

# ~2048, 16MB, FAT, bootable
# ~rest of drive, Ext4

PARTITION_BOOT_OFFSET=2048
PARTITION_ROOT_OFFSET=34815

fdisk $DRIVE >/dev/null 2>&1 <<EOF
n
p
1
$PARTITION_BOOT_OFFSET
$PARTITION_ROOT_OFFSET
n
p
2


w
EOF

sync

# The partition name prefix depends on the device name:
# - /dev/sdX -> /dev/sdXY
# - /dev/mmcblkX -> /dev/mmcblkXpY
if echo ${DRIVE}|grep -q mmcblk ; then
	PART="p"
else
	PART=""
fi

BOOT_PART=${DRIVE}${PART}1
ROOT_PART=${DRIVE}${PART}2

if [ -b ${BOOT_PART} ]; then
	umount ${BOOT_PART}
	mkfs.vfat -n "BOOT" ${BOOT_PART}
else
	echo "Cant find boot partition in /dev"
	exit 1
fi

if [ -b ${ROOT_PART} ]; then
	umount ${ROOT_PART}
	mkfs.ext4 ${ROOT_PART}
else
	echo "Cant find root partition in /dev"
	exit 1
fi

mount $BOOT_PART $P1
mount $ROOT_PART $P2

# write uImage
cp $UIMAGE $P1
# write board file
if [ -e $BIN_BOARD_FILE ]; then
	cp $BIN_BOARD_FILE $P1
fi

# write devicetree blob 
if [ -e $FDT_IMG ]; then
	cp $FDT_IMG $P1
fi

# write u-boot script
cp $BOOT_CMD_H $P1

# write rootfs
tar -C $P2 -xf $ROOTFS

sync

umount $P1
umount $P2

rmdir $P1
rmdir $P2

dd if=$SPL_IMG of=$DRIVE bs=1024 seek=8
