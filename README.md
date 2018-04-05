## Introduction

This guide will give you detailed instructions on how to install linux on
a LVM loopback disk booting from a USB drive (grub and boot partition) without
have to change your PC internal disk boot sector.


## Conventions

"$${{ ... }}" : provide your own data/parameter.

## Pre-requisites

Boot from Live Debian distribution
Insert a USB drive for OS booting and umount it

	sudo su -

## Parameters

Set following parameters as you need:

	PARAM_BOOT_DEV=/dev/sdc
	PARAM_BOOT_PART=1
	PARAM_HOST_UUID=$(blkid -s UUID -o value -t LABEL=OS)
	PARAM_HOST_UUID_FSTYPE=ntfs
	PARAM_LOOP_DIR=.linux-loops
	PARAM_LOOP_SIZE=100
	PARAM_LVM_VG=vg_system
	PARAM_LVM_LV_ROOT=lv_root
	PARAM_LVM_LV_SWAP=lv_swap
	PARAM_LVM_LV_SWAP_SIZE=16G

## Environment setup

	BOOT_MNT=/mnt/boot
	BOOT_PART=${PARAM_BOOT_DEV}${PARAM_BOOT_PART}
	HOST_UUID=UUID=${PARAM_HOST_UUID}
	HOST_MNT=/mnt/host
	LOOP_DEV=$(losetup -f)
	LOOP_FILE=${HOST_MNT}/${PARAM_LOOP_DIR}/${PARAM_LVM_VG}0.lvm
	LVM_TARGET_MNT=/mnt/target
	LVM_DEFAULT_CONF=${LVM_TARGET_MNT}/etc/default
	LVM_GRUB_CONF=${LVM_TARGET_MNT}/etc/grub.d
	LVM_INITRAMFS_CONF=${LVM_TARGET_MNT}/etc/initramfs-tools/conf.din
	LVM_INITRAMFS_SCRIPTS=${LVM_TARGET_MNT}/etc/initramfs-tools/scripts
	LVM_LOGROTATE_CONF=${LVM_TARGET_MNT}/etc/logrotate.d/rsyslog
	LVM_RSYSLOG_CONF=${LVM_TARGET_MNT}/etc/rsyslog.d
	LVM_LV_ROOT_DEV=/dev/${PARAM_LVM_VG}/${PARAM_LVM_LV_ROOT}

## Loop file system setup

	mkdir -p ${HOST_MNT}
	mount ${HOST_UUID} ${HOST_MNT}

	dd status=progress if=/dev/zero of=${LOOP_FILE} bs=1G count=${PARAM_LOOP_SIZE}

	losetup ${LOOP_DEV} ${LOOP_FILE}

	pvcreate -v ${LOOP_DEV}
	vgcreate -v ${PARAM_LVM_VG} ${LOOP_DEV}

	lvcreate -v -L ${PARAM_LVM_LV_SWAP_SIZE} -n ${PARAM_LVM_LV_SWAP} ${PARAM_LVM_VG}

	lvcreate -v -l 100%FREE -n ${PARAM_LVM_LV_ROOT} ${PARAM_LVM_VG}

## Install

	ubiquity &
	  - Partitioning: something else
	  - "Device for boot loader installation": ${PARAM_BOOT_DEV}
	  - ${BOOT_PART} ext4 512Mb @ "/boot"
	  - ${PARAM_LVM_LV_ROOT} @ "/"
	  - ${PARAM_LVM_LV_SWAP} @ "swap"
	  - Click on "Continue testing"

## Init RAM FS scripting

	mkdir -p ${LVM_INITRAMFS_MNT}
	mount ${LVM_LV_ROOT_DEV} ${LVM_INITRAMFS_MNT}

	cp scripts/initramfs/lvm-loops-setup ${LVM_INITRAMFS_SCRIPTS}/local-top/
	chmod +x ${LVM_INITRAMFS_SCRIPTS}/local-top/*

	cp scripts/initramfs/lvm-loops-finalize ${LVM_INITRAMFS_SCRIPTS}/local-bottom/
	chmod +x ${LVM_INITRAMFS_SCRIPTS}/local-bottom/*

	cp script/initramfs/compress ${LVM_INITRAMFS_CONF}

	chroot ${LVM_INITRAMFS_MNT} /usr/sbin/update-initramfs -uv -k all

	mkdir -p ${BOOT_MNT}
	mount ${BOOT_PART} ${BOOT_MNT}

	mv ${LVM_INITRAMFS_MNT}/boot/* ${BOOT_MNT}

## Filter out loops error messages

In order to keep your syslog file clean clean (please look at **Known issues** section) do:

	cp scripts/rsyslog/30-loop-errors.conf ${LVM_RSYSLOG_CONF}

	vi ${LVM_LOGROTATE_CONF}:
		- add "/var/log/loop-errors.log" to the log files list

## Grub configuration

Add settings to **grub.cfg** header:

	vi ${LVM_DEFAULT_CONF}/grub

	  - GRUB_TIMEOUT=10
	  - GRUB_TIMEOUT_STYLE="menu"

	cp scripts/grub/linux-on-loopback-usb.cfg ${LVM_DEFAULT_CONF}
	cp scripts/grub/10_linux-on-loopback-usb ${LVM_GRUB_CONF}

Customize **${LVM_DEFAULT_CONF}/linux-on-loopback-usb.cfg** with your own settings (<< ... >>)...

	chroot ${LVM_INITRAMFS_MNT} /usr/sbin/update-grub -o ${BOOT_MNT}/grub/grub.cfg

## Start your new OS

	sync
	umount -a

Now insert your USB key then:

	reboot

## Grub update

After rebooting...

	sudo su -

	chmod -x /etc/grub.d/10*

	vi /etc/default/grub
	  - GRUB_DEFAULT="Loopback"
	  - GRUB_TIMEOUT=10
	  - GRUB_TIMEOUT_STYLE="menu"

	update-grub

## Finally start OS!

	reboot

... now enjoy yourself **;)** ...

## Restore boot USB drive to a new one

In order to use the **restore-boot-usb-drive** tool you have to prepare a fresh USB drive:

- Destroy all partitions.
- Create a new 512Mb ext4 partition.
- Flag it as BOOTable (else you will get an **"Invalid partition table"** warning at boot that you may skip by pressing ESC).
- If you wish, partition remaining space as FAT32.
- Now run **restore-boot-usb-drive** to get help on its command line parameters.

## FAQ

1. If you create a new USB boot drive remember to update the boot partition UUID inside FSTAB, or use the form **/dev/xxxyy** to make it independent.
2. Schedule **backup-boot-usb-drive** to a cloud drive in order to make your system bootable due to a USB drive failure (restore backups by **restore-boot-usb-drive**).
3. You can install on MMC too (put **/dev/mmcblk0p1** on FSTAB as **/boot**).

## Known issues

1. Unclean shutdown : mitigated by EXT4 journal recover (to be fixed).
2. Syslog error "blk_update_request: I/O error, dev loop**X**, sector **X**" : it disappears on kernel 4.13 or above.
3. Syslog error "print_req_error:: I/O error, dev loop**X**, sector **X**": get logged only once on kernel 4.15.
4. LVM swap file causes a total system freeze on heavy memory load. After a lot of search and experimentation, the only workaround I have found is to create a standalone swap file hosted inside the same folder of the LVM loop files.

## Some references

1. [blk_update_request: I/O error (1)](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1526537)
- [blk_update_request: I/O error (2)](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1526537)
- [blk_update_request: I/O error (3)](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1526537/comments/27)
- [Block: loop: improve performance via blk-mq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b5dd2f6047ca108001328aac0e8588edd15f1778)
- [eMMC transfer speed significantly slower than stock u-boot](https://github.com/madisongh/meta-tegra/issues/42)
- [Ensure that loopback root and host are unmounted on shutdown](https://unix.stackexchange.com/questions/61144/ensure-that-loopback-root-and-host-are-unmounted-on-shutdown)
- [High load freezes ubuntu completely everytime](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1555351/comments/16)
- [Hint: "blk_update_request: I/O error, dev loop0, sector xxxxxxxx" + freezing system (SSD) workaround?](https://github.com/hakuna-m/wubiuefi/issues/16)
- [Kernel Hard Freezing Very Often](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/908335/comments/84)
- [Linux File Systems: Ext2 vs Ext3 vs Ext4](https://www.thegeekstuff.com/2011/05/ext2-ext3-ext4/)
- [System freeze on high memory usage](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073/comments/48)
- [System freeze on high memory usage](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356/comments/71)
