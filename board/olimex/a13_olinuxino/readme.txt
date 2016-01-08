A13-OLinuXino-MICRO

Intro
=====

These are open hardware boards, based an the AllWinners A13 SoC.

for more details about the boards see the following pages:
 - https://www.olimex.com/Products/OLinuXino/open-source-hardware
 - https://www.olimex.com/Products/OLinuXino/A13/A13-OLinuXino-MICRO/

The following defconfig is available:
 - olimex_a13_olinuxino_micro_defconfig
   for the A13-OLinuXino-MICRO board using linux-sunxi kernel

(see http://linux-sunxi.org/Linux_Kernel for more details)

How to build it
===============

Configure Buildroot:

    $ make olimex_a13_olinuxino_micro_defconfig

Compile everything and build the rootfs image:

    $ make

Result of the build
-------------------

After building, you should get a tree like this:

    output/images/
    +-- boot.scr
    +-- rootfs.ext2
    +-- rootfs.ext4 -> rootfs.ext2
    +-- rootfs.tar
    +-- sun5i-a13-olinuxino-micro.dtb
    +-- u-boot-sunxi-with-spl.bin
    +-- u-boot.bin
    `-- uImage


How to write the SD card
========================

On buildroot root directory call the script make-sdimg.sh :

	sudo board/olimex/a13_olinuxino/make-sdimg.sh output/images /dev/sdX

After that the SD card is ready.

Finish
======

Eject the SD card, insert it in the A13-OLinuXino board, and power it up.

