#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

. /lib/dracut-lib.sh

info "Shutting down LVM loops host device and mount points..."

umount /oldroot 2>&1 | vinfo

lvm vgchange -an --noudevsync 2>&1 | vinfo

losetup -D 2>&1 | vinfo

umount /oldsys/host 2>&1 | vinfo
umount /oldsys/run/initramfs/host 2>&1 | vinfo