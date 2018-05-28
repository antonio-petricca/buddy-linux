#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

. /lib/dracut-lib.sh

info "Mounting LVM loop device(s)..."

LVM_LOOPS_HOST_DEV=""
LVM_LOOPS_HOST_FSOPTIONS=""
LVM_LOOPS_HOST_FSTYPE=""
LVM_LOOPS_MASK=""
MNT=/run/initramfs/host

for param in $(cat /proc/cmdline); do
    case $param in
        lvm_loops_host_dev=*)
            LVM_LOOPS_HOST_DEV=${param#lvm_loops_host_dev=}
        ;;

        lvm_loops_host_fsoptions=*)
            LVM_LOOPS_HOST_FSOPTIONS=${param#lvm_loops_host_fsoptions=}
        ;;

        lvm_loops_host_fstype=*)
            LVM_LOOPS_HOST_FSTYPE=${param#lvm_loops_host_fstype=}
        ;;

        lvm_loops_mask=*)
            LVM_LOOPS_MASK=${param#lvm_loops_mask=}
        ;;

    esac
done

if [ "${LVM_LOOPS_HOST_DEV}" = "" ] || [ "${LVM_LOOPS_HOST_FSTYPE}" = "" ] || [ "${LVM_LOOPS_MASK}" = "" ]; then
  warn "One ore more arguments missing.LVM loops mount skipped."
  exit 0
fi

HOST_DEV=$(/sbin/blkid -U ${LVM_LOOPS_HOST_DEV})
info "Mounting LVM host \"${LVM_LOOPS_HOST_DEV}\" (${HOST_DEV}) ..."

[ -d ${MNT} ] || mkdir ${MNT} 2>&1 | vinfo

if [ "${LVM_LOOPS_HOST_FSTYPE}" == "ntfs" ] || [ "${LVM_LOOPS_HOST_FSTYPE}" == "ntfs-3g" ]; then
  # Prevent "systemd" from killing fuse driver daemon

  # https://github.com/systemd/systemd/blob/5d13a15b1d0bd7d218100d204a84eaaaaeab932f/src/core/killall.c
  # https://www.freedesktop.org/wiki/Software/systemd/RootStorageDaemons/

  exec -a @ntfs-3g ntfs-3g ${HOST_DEV} ${MNT} 2>&1 | vinfo
else
  modprobe ${LVM_LOOPS_HOST_FSTYPE} 2>&1 | vinfo
  mount -t ${LVM_LOOPS_HOST_FSTYPE} ${HOST_DEV} ${MNT} 2>&1 | vinfo
fi

if [ ! -z "${LVM_LOOPS_HOST_FSOPTIONS}" ]; then
  mount -o remount,${LVM_LOOPS_HOST_FSOPTIONS} ${MNT} 2>&1 | vinfo
fi

LOOPS="${MNT}/${LVM_LOOPS_MASK}"
info "Setting up LVM loops \"${LOOPS}\" ..."

for loop in ${LOOPS}; do

  losetup -f $loop 2>&1 | vinfo

  if [ $? = 0 ]; then
    info "\"$loop\" setup."
  else
    warn "Cannot setup loop file \"$loop\"."
  fi

done

info "Activate logical volumes..."

lvm pvscan 2>&1 | vinfo
lvm vgscan 2>&1 | vinfo
lvm lvscan 2>&1 | vinfo
lvm vgchange -ay 2>&1 | vinfo

info "Request for shutdown services..."

need_shutdown

info "Done"
