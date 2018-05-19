# Buddy Linux (Experts Guide)

## Introduction

This guide will provide you detailed instructions, as an alternative to the automated **install** script on how to install Linux on a LVM loopback disk booting from an arbitrary device (grub and boot partition), like a USB drive, without have to write to your PC internal disk boot sector.

## Conventions

`{{ ... }}` : provide your own data/parameter.

## Pre-requisites

- Boot from a Live Debian or derivated distribution.
- Insert a USB drive for bootloader, then umount it (if you want to boot from an external device).

## Clone repository

```
sudo apt-get install git
git clone https://github.com/antonio-petricca/buddy-linux.git
cd buddy-linux

sudo su -
```

## Parameters

Set following (example) parameters as you need:

```bash
PARAM_BOOT_DEV=/dev/sdc
PARAM_BOOT_PART=1
PARAM_HOST_UUID=$(blkid -s UUID -o value -t LABEL=OS)
PARAM_HOST_FSTYPE=ntfs-3g
PARAM_HOST_FSOPTIONS=noatime
PARAM_LOOP_DIR=.linux-loops
PARAM_LOOP_SIZE=100
PARAM_LVM_VG=vg_system
PARAM_LVM_LV_ROOT=lv_root
PARAM_LVM_LV_SWAP=lv_swap
PARAM_LVM_LV_SWAP_SIZE=16G
```

## Environment setup

```bash
BOOT_MNT=/mnt/boot
BOOT_PART=${PARAM_BOOT_DEV}${PARAM_BOOT_PART}
HOST_UUID=UUID=${PARAM_HOST_UUID}
HOST_MNT=/mnt/host
LOOP_DEV=$(losetup -f)
LOOP_DIR=${HOST_MNT}/${PARAM_LOOP_DIR}
LOOP_FILE=${LOOP_DIR}/${PARAM_LVM_VG}0.lvm
LOOP_SIZE=$((PARAM_LOOP_SIZE * 1000))
LVM_TARGET_MNT=/mnt/target
LVM_DEFAULT_CONF=${LVM_TARGET_MNT}/etc/default
LVM_GRUB_CONF=${LVM_TARGET_MNT}/etc/grub.d
LVM_DRACUT_CONF=${LVM_TARGET_MNT}/etc/dracut.conf.d
LVM_DRACUT_MODULES=${LVM_TARGET_MNT}/usr/lib/dracut/modules.d
LVM_INITRAMFS_CONF=${LVM_TARGET_MNT}/etc/initramfs-tools/conf.din
LVM_INITRAMFS_SCRIPTS=${LVM_TARGET_MNT}/etc/initramfs-tools/scripts
LVM_LOGROTATE_CONF=${LVM_TARGET_MNT}/etc/logrotate.d
LVM_RSYSLOG_CONF=${LVM_TARGET_MNT}/etc/rsyslog.d
LVM_LV_ROOT_DEV=/dev/${PARAM_LVM_VG}/${PARAM_LVM_LV_ROOT}
```

## System loop files setup

**Attention**: I suggest you to create a NON LVM swap file because it cannot be accessed as a raw partition, avoiding you system freeze on low memory.

```bash
mkdir -p ${HOST_MNT}
mount ${HOST_UUID} ${HOST_MNT}

dd status=progress if=/dev/zero of=${LOOP_FILE} bs=1M count=${LOOP_SIZE}

losetup ${LOOP_DEV} ${LOOP_FILE}

pvcreate -v ${LOOP_DEV}
vgcreate -v ${PARAM_LVM_VG} ${LOOP_DEV}

lvcreate -v -L ${PARAM_LVM_LV_SWAP_SIZE} -n ${PARAM_LVM_LV_SWAP} ${PARAM_LVM_VG}

lvcreate -v -l 100%FREE -n ${PARAM_LVM_LV_ROOT} ${PARAM_LVM_VG}
```

## Linux distribution install

```bash
ubiquity &
  - Partitioning: something else
  - "Device for boot loader installation": ${PARAM_BOOT_DEV}
  - ${BOOT_PART} ext4 512Mb @ "/boot"
  - /dev/mapper/${PARAM_LVM_VG}-${PARAM_LVM_LV_ROOT} @ "/"
  - ${PARAM_LVM_LV_SWAP} @ "swap"
  - Click on "Install Now"
```

## Build InitRd image

```bash
mkdir -p ${LVM_TARGET_MNT}
mount ${LVM_LV_ROOT_DEV} ${LVM_TARGET_MNT}

mkdir -p ${BOOT_MNT}
mount ${BOOT_PART} ${BOOT_MNT}

echo "nameserver 8.8.8.8" > ${LVM_TARGET_MNT}/etc/resolv.conf
```

### InitRamFs Tools

```bash
cp assets/initramfs/lvm-loops-setup ${LVM_INITRAMFS_SCRIPTS}/local-top/
chmod +x ${LVM_INITRAMFS_SCRIPTS}/local-top/*

cp assets/initramfs/lvm-loops-finalize ${LVM_INITRAMFS_SCRIPTS}/local-bottom/
chmod +x ${LVM_INITRAMFS_SCRIPTS}/local-bottom/*

cp assets/initramfs/compress ${LVM_INITRAMFS_CONF}

chroot ${LVM_TARGET_MNT} /usr/sbin/update-initramfs -uv -k all
mv -v ${LVM_TARGET_MNT}/boot/* ${BOOT_MNT}
```

### Dracut

```bash

mount --bind /dev ${LVM_TARGET_MNT}/dev
mount --bind /dev ${LVM_TARGET_MNT}/dev/pts
mount --bind /sys ${LVM_TARGET_MNT}/sys
mount --bind /proc ${LVM_TARGET_MNT}/proc
mount --bind /run ${LVM_TARGET_MNT}/run
mount --bind ${BOOT_MNT} ${LVM_TARGET_MNT}/boot

chroot ${LVM_TARGET_MNT} /usr/bin/apt-get install -y --no-install-recommends dracut

cp -v assets/dracut/*.conf ${LVM_DRACUT_CONF}/
cp -rv assets/dracut/90buddy-linux/ ${LVM_DRACUT_MODULES}/

cp assets/dracut/update-dracut ${LVM_TARGET_MNT}/sbin/
chroot ${LVM_TARGET_MNT} /sbin/update-dracut

umount ${LVM_TARGET_MNT}/dev/pts
umount ${LVM_TARGET_MNT}/dev
umount ${LVM_TARGET_MNT}/sys
umount ${LVM_TARGET_MNT}/proc
umount ${LVM_TARGET_MNT}/run
umount ${LVM_TARGET_MNT}/boot

```

## Grub configuration

Add settings to **grub.cfg** header:

- `vi ${LVM_DEFAULT_CONF}/grub`

  - Set `GRUB_TIMEOUT=30`
  - Set `GRUB_TIMEOUT_STYLE="menu"`

- `cp -v assets/grub/buddy-linux.cfg ${LVM_DEFAULT_CONF}/grub.d/`
- `cp -v assets/grub/10_buddy-linux ${LVM_GRUB_CONF}/`
- `chmod -x ${LVM_GRUB_CONF}/10_linux`

Customize `${LVM_DEFAULT_CONF}/grub.d/buddy-linux.cfg` with your own settings (`$${{ ... }}`) ignoring any LVM warning...

```bash
mount --bind /dev ${LVM_TARGET_MNT}/dev
mount --bind /dev ${LVM_TARGET_MNT}/dev/pts
mount --bind /sys ${LVM_TARGET_MNT}/sys
mount --bind /proc ${LVM_TARGET_MNT}/proc
mount --bind ${BOOT_MNT} ${LVM_TARGET_MNT}/boot

chroot ${LVM_TARGET_MNT} /usr/sbin/update-grub

umount ${LVM_TARGET_MNT}/dev/pts
umount ${LVM_TARGET_MNT}/dev
umount ${LVM_TARGET_MNT}/sys
umount ${LVM_TARGET_MNT}/proc
umount ${LVM_TARGET_MNT}/boot

```

## Filter out loops error messages

In order to keep your syslog file clean clean (please look at **Known issues** section) do:

```bash
cp assets/rsyslog/30-loop-errors.conf ${LVM_RSYSLOG_CONF}/
cp assets/rsyslog/buddy-linux ${LVM_LOGROTATE_CONF}/
```

## Finally start Linux

```bash
sync
reboot
```

## Restore boot USB drive to a new one

In order to use the `restore-boot-usb-drive` tool you have to prepare a fresh USB drive:

- Destroy all partitions.
- Create a new 512Mb ext4 partition.
- Flag it as BOOTable (else you will get an **"Invalid partition table"** warning at boot that you may skip by pressing ESC).
- If you wish, partition remaining space as FAT32.
- Now run `restore-boot-usb-drive` to get help on its command line parameters.

## FAQ

1. If you create a new USB boot drive remember to update the boot partition UUID inside FSTAB, or use the form **/dev/xxxyy** to make it independent.
2. Schedule `backup-boot-usb-drive` to a cloud drive in order to make your system bootable due to a USB drive failure (restore backups by **restore-boot-usb-drive**).
3. You can install on MMC too (put **/dev/mmcblk0p1** on FSTAB as **/boot**).
4. If you host your loopback files on a NTFS volume you can gain performances by setting `HOST_DEV_FSOPTIONS=noatime,async,big_writes` inside **buddy-linux.cfg**.
5. **Systemd** debug:
  - [Kernel](https://freedesktop.org/wiki/Software/systemd/Debugging/) debug parameters: `systemd.log_level=debug systemd.log_target=console console=ttyS0,38400 console=tty1`
  - [Client](https://gist.github.com/snb/284940/11e6354f170be602c9c2f67b59d489ed49ebd143: `screen /tmp/host-pipe.socket`

## Known issues

1. Unclean shutdown : mitigated by EXT4 journal recover (to be fixed).
2. Syslog error "blk_update_request: I/O error, dev loop**X**, sector **X**" : it disappears on kernel 4.13 or above.
3. Syslog error "print_req_error:: I/O error, dev loop**X**, sector **X**": get logged only once on kernel 4.15.
4. Swap file on loopback device causes a total system freeze on heavy memory load. After a lot of search and experimentation, the only workaround I have found is to create a standalone swap file hosted inside the same folder of the LVM loop files.
5. In case of rollback from _Dracut_, **update-initramfs -u -k all** does not recognize all the installed kernels, so you have to update the missing ones by hand.

## Some references

- [A Quick Dracut Module](https://rich0gentoo.wordpress.com/2012/01/21/a-quick-dracut-module/)
- [Back to “initramfs” on Debian by systemd “shutdown to initramfs” feature](https://unix.stackexchange.com/questions/436707/back-to-initramfs-on-debian-by-systemd-shutdown-to-initramfs-feature)
- [blk_update_request: I/O error (1)](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1526537)
- [blk_update_request: I/O error (2)](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1526537)
- [blk_update_request: I/O error (3)](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1526537/comments/27)
- [Block: loop: improve performance via blk-mq](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b5dd2f6047ca108001328aac0e8588edd15f1778)
- [Clean shutdown with systemd](http://www.slax.org/blog/24229-Clean-shutdown-with-systemd.html)
- [CentOS7 Dracut lvm command not found](https://serverfault.com/questions/893721/centos7-dracut-lvm-command-not-found)
- [Bug#778849: Support restoring initrd on shutdown and pivoting into it](https://lists.debian.org/debian-kernel/2017/04/msg00079.html)
- [Diagnosing Boot Problems](https://freedesktop.org/wiki/Software/systemd/Debugging/)
- [Dracut introduction](https://events.static.linuxfound.org/images/stories/pdf/lcjp2012_cong_wang.pdf)
- [dracut-ntfsloop: Mount image on NTFS partition](https://github.com/rgcjonas/dracut-ntfsloop)
- [dracut-shutdown (8) ](https://www.systutorials.com/docs/linux/man/8-dracut-shutdown/)
- [dracut-shutdown.service](http://manpages.ubuntu.com/manpages/bionic/man8/dracut-shutdown.service.8.html)
- [eMMC transfer speed significantly slower than stock u-boot](https://github.com/madisongh/meta-tegra/issues/42)
- [Ensure that loopback root and host are unmounted on shutdown](https://unix.stackexchange.com/questions/61144/ensure-that-loopback-root-and-host-are-unmounted-on-shutdown)
- [High load freezes ubuntu completely everytime](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1555351/comments/16)
- [Hint: "blk_update_request: I/O error, dev loop0, sector xxxxxxxx" + freezing system (SSD) workaround?](https://github.com/hakuna-m/wubiuefi/issues/16)
- [How to debug Dracut problems](https://fedoraproject.org/wiki/How_to_debug_Dracut_problems)
- [How to debug Systemd problems](https://fedoraproject.org/wiki/How_to_debug_Systemd_problems)
- [Kernel Hard Freezing Very Often](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/908335/comments/84)
- [Linux File Systems: Ext2 vs Ext3 vs Ext4](https://www.thegeekstuff.com/2011/05/ext2-ext3-ext4/)
- [Netconsole](https://wiki.archlinux.org/index.php/Netconsole)
- [Netconsole](https://fedoraproject.org/wiki/Netconsole)
- [systemd/src/core/killall.c](https://github.com/systemd/systemd/blob/5d13a15b1d0bd7d218100d204a84eaaaaeab932f/src/core/killall.c)
- [systemd and Storage Daemons for the Root File System](https://www.freedesktop.org/wiki/Software/systemd/RootStorageDaemons/)
- [systemd shutdown: switch-root after remounting root fs ro](https://lists.freedesktop.org/archives/systemd-devel/2015-December/035218.html)
- [System freeze on high memory usage](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1162073/comments/48)
- [System freeze on high memory usage](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/159356/comments/71)
- [The initrd Interface of systemd](https://www.freedesktop.org/wiki/Software/systemd/InitrdInterface/)
- [vgchange may deadlock in initramfs when VG present that's not used for rootfs](https://bugs.launchpad.net/ubuntu/+source/lvm2/+bug/802626/comments/17)
- [Virtualbox serial console](https://gist.github.com/snb/284940/11e6354f170be602c9c2f67b59d489ed49ebd143)
