# Linux on Loopback devices and USB bootstrap

## Introduction

Do you remember [Wubi Ubuntu Installer](https://en.wikipedia.org/wiki/Wubi_(software))?

This project is either a replacement and an improvement of **Wubi**, obviously with its pros and cons.

You will be able to install your [Debian](https://www.debian.org/index.it.html) (or derived) distribution on a PC without repartitioning it, simply by using a secondary/external boot device.

### PROs

- The [Grub 2](https://help.ubuntu.com/community/Grub2) bootloader can be installed on any device partitio, external or internal.
- You can host your loopback device files on any partition type, not only on NTFS ones.
- Loopback device files partecipate to a [LVM](https://wiki.archlinux.org/index.php/LVM) physical volume cluster, so after a successfully installation, you can increase your logical volume size as you need (by booting with any Linux Live Distribution to extend it).
- [Dracut](https://dracut.wiki.kernel.org/index.php/Main_Page) can be choosen (it is the default one) as _initramfs_ infrastructure. By its implementation of the [Systemd Shutdown process](https://www.systutorials.com/docs/linux/man/8-dracut-shutdown/) the loopback devices are safely released without any data loss.
- Your OS can be upgraded to all future distributions (Wuby were pinned on a not upgradable Ubuntu release).

## Pre-requisites

- Boot from a Live Debian or derivated distribution.
- Insert a USB drive for bootloader, then umount it (if you want to boot from an external device).

## Clone repository

```
sudo apt-get install git

git clone https://github.com/DareDevil73/linux-on-loopback-usb.git
cd linux-on-loopback-usb

sudo su -
```

## Become friend of the install script

The automated **install** script will guide you through the whole setup process.

You should simply follow the instructions provided by it. Even if something will go wrong, due to an error or by a negative answer to some question, you can resume the setup from the line number printed out by the script (_--resume_).

Here is the parameteres list...

```
install [OPTIONS]

    Executive arguments:

      -h | --help                 : this screen.
      -c | --clean                : clean already performed steps.
      -r | --resume               : resume execution from a given line number.

    Mandatory arguments:

      -b | --boot-device          : boot (USB) device (eg: /dev/sdc).
      -u | --host-uuid            : loop files host device UUID (got by blkid).
      -f | --host-fs-type         : host device filesystem type (default: "ntfs-3g").
      -s | --loopback-file-size   : loopback main file size (in Gigabytes).
      -w | --swap-file-size       : swap file size (in Gigabytes).

    Optional arguments:

      -p | --boot-partition-index : boot partition index (default: 1).
      -i | --initrd-tool          : IniRD tools => 1 = initramfs-tools, 2 = dracut (default: 2).
      -o | --host-fs-options      : host device filesystem options (default: "noatime").
      -d | --loops-dir            : host device loopback files root relative folder (default: ".linux-loops").
      -v | --volume-group-name    : volume group name (default: "vg_system").
      -l | --logical-volume-name  : root logical volume name (default: "lv_root").
```

## An example is worth a thousand words

Suppose we want to take advantage of Linux on our company notebook equipped with Windows that we absolutely cannot repartition.

For the same reason we cannot make a dual boot system.

We have to gather some information to pass to install script, so...

### Get the UUID of the host disk

The host disk is the notebook internal drive partition where we want to create the (first) loopback file where we will install our Linux.

```
$ blkid

/dev/sda1: LABEL="ESP" UUID="E00C-5421" TYPE="vfat" PARTLABEL="EFI system partition" PARTUUID="fb4ed2b9-80ee-4585-ba9a-98ad5fff9577"
/dev/sda2: LABEL="DIAGS" UUID="6C3A-F782" TYPE="vfat" PARTLABEL="Basic data partition" PARTUUID="90215d40-b38b-4491-b8da-0aa0b1e49f22"
/dev/sda4: LABEL="WINRETOOLS" UUID="4CE43CC1E43CAED8" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="9153f739-1837-4e62-94f7-0c303920be7b"
/dev/sda5: LABEL="OS" UUID="C69E53819E536947" TYPE="ntfs" PARTUUID="1f2bc4d8-3919-4bd1-8d7f-14a16f1ea89e"
/dev/sda6: UUID="FCD2CC27D2CBE3CC" TYPE="ntfs" PARTUUID="2a28eaa5-f129-4a31-a0a2-71bbb25a1cf0"
/dev/sda7: LABEL="PBR Image" UUID="FCACE750ACE7044C" TYPE="ntfs" PARTLABEL="Microsoft recovery partition" PARTUUID="b4df6e39-9c55-4eb5-a374-113026760c60"

```

**/dev/sda5** is what we are searching for, so the UUID is **C69E53819E536947**.

### Get the (USB) drive device name

The USB drive is the disk where Grub will be installed and that will host the boot partition (/boot).

So,

```
$ lsblk

NAME                MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sdb                   8:16   1   7,5G  0 disk
└─sdb1                8:17   1  1000M  0 part /media/817697da-efa5-49da-baeb-ca175d9b587b
sda                   8:0    0 931,5G  0 disk
├─sda4                8:4    0   750M  0 part
├─sda2                8:2    0    40M  0 part
├─sda7                8:7    0     7G  0 part
├─sda5                8:5    0 922,7G  0 part
├─sda3                8:3    0   128M  0 part
├─sda1                8:1    0   500M  0 part
└─sda6      8:6    0   459M  0 part

$ sudo umount /dev/sdb1
```

Thus, **/dev/sdb** will host the Grub bootloader, and **/dev/sdb1** the boot partition (_--boot-partition-index 1_).

### Define the remaining parameters

Our notebook is equipped with a 1 Tb SATA disk (formatted as NTFS) and 8Gb of RAM, so we choose:

- **250 Gb** for the (first) loopback device file.
- **16 Gb** for the swap file (2 x installed RAM).
- **ntfs-3g** file system type.
- **Dracut** as initramfs infrastructure (better shutdown process handling).

### Run the install script

Is time to go...

```
$ ./install  \
  --host-uuid C69E53819E536947 \
  --boot-device /dev/sdb \
  --boot-partition-index 1 \
  --host-fs-type ntfs-3g \
  --loopback-file-size 250 \
  --swap-file-size 16
```

Pay much attention to the Ubiquity step, then enjoy with your Linux setup!