## Introduction

This guide will give you a fully detail instructions on how to install linux on
a LVM loopback disk booting from a USB drive (grub and boot partition) without
have to change your PC internal disk boot sector.


## Conventions

"<< ... >>" : provide your own data/parameter.


## Pre-requisites

Boot from Live Debian distribution
Insert a USB drive for OS booting and umount it

	sudo su -

## Parameters

Fit following parameters as you need:

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
	LVM_INITRAMFS_MNT=/mnt/target
	LVM_INITRAMFS_SCRIPT=${LVM_INITRAMFS_MNT}/etc/initramfs-tools/scripts/local-top/loops-lvm
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
	
	cp loops-lvm ${LVM_INITRAMFS_SCRIPT}
	chmod +x ${LVM_INITRAMFS_SCRIPT}
	chroot ${LVM_INITRAMFS_MNT} /usr/sbin/update-initramfs -uv
	
	mkdir -p ${BOOT_MNT}
	mount ${BOOT_PART} ${BOOT_MNT}
	
	mv ${LVM_INITRAMFS_MNT}/boot/* ${BOOT_MNT}
	
## FSTAB update

	mkdir ${LVM_INITRAMFS_MNT}/host
	
	vi ${LVM_INITRAMFS_MNT}/etc/fstab
	
		add "<<${HOST_UUID}>>   /host   <<${PARAM_HOST_UUID_FSTYPE}>>    default 0   1"
	
## Grub configuration

	vi ${BOOT_MNT}/grub/custom.cfg 

Customize it as follow:

	set BOOT_PART=(hd0,msdos1)
	set HOST_DEV=<<${PARAM_HOST_UUID}>>
	set HOST_DEV_FSTYPE=<<${PARAM_HOST_UUID_FSTYPE}>>
	set ROOT_DEV=<<${LVM_LV_ROOT_DEV}>>
	
	set LVM_LOOPS_MASK=<<${PARAM_LOOP_DIR}/${PARAM_LVM_VG}*.lvm>>
	set MAX_LOOPS=32
	
	menuentry 'Loopback' --class ubuntu --class gnu-linux --class gnu --class os {
	    echo "Initializing environment..."
	
	    set KERN_VER=4.10.0-38-generic
	
	    recordfail
		load_video
		gfxmode $linux_gfx_mode
	
	    echo "Loading modules..."
	
	    insmod ext2
	    insmod gzio
	    insmod part_msdos
	
	    echo "Loading kernel..."
	
	    set root=${BOOT_PART}
	
	    linux  /vmlinuz-${KERN_VER} root=${ROOT_DEV} lvm_loops_host_dev=${HOST_DEV} lvm_loops_host_fstype=${HOST_DEV_FSTYPE} lvm_loops_mask=${LVM_LOOPS_MASK} max_loop=${MAX_LOOPS} ro verbose nosplash
	    
	    initrd /initrd.img-${KERN_VER}
	}

## Start your new OS

	sync
	umount -a

Now insert your USB key, press ESC and select "**Loopback**" grub menu entry:

	reboot

## Grub update

After rebooting...

	sudo su -
	
	chmod -x /etc/grub.d/10*
	
	vi /etc/default/grub
	  - set: GRUB_DEFAULT="Loopback"
	  
	update-grub

## Finally start OS!

	reboot

... now enjoy yourself **;)** ...

## Known issues

- Unclean shutdown (mitigated by EXT4 journal recover).

## Troubleshooting

- If you create a new USB boot drive remember to update the boot partition UUID inside FSTAB, or use the form **/dev/xxxyy** to make it independent.
- Schedule **backup-boot-usb-drive** to a cloud drive in order to make your system bootable due to a USB drive failure (restore backups by **restore-boot-usb-drive**).

## Some references

- https://unix.stackexchange.com/questions/61144/ensure-that-loopback-root-and-host-are-unmounted-on-shutdown
