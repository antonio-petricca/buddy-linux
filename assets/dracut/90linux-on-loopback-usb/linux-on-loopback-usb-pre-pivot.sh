#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

. /lib/dracut-lib.sh

MNT=/run/initramfs/host
SYS_ROOT=/sysroot
ROOT_MNT=${SYS_ROOT}/host

info "Bind LVM loops host device mount point from \"${MNT}\" to \"${ROOT_MNT}\"..."

mount -o remount,rw ${SYS_ROOT} 2>&1 | vinfo

[ -d ${ROOT_MNT} ] || (mkdir -p ${ROOT_MNT} && chmod 755 ${ROOT_MNT}) 2>&1 | vinfo

mount --bind ${MNT} ${ROOT_MNT} 2>&1 | vinfo
