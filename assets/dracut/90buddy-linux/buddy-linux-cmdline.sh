#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

. /lib/dracut-lib.sh

info "Configuring LVM loop(s) host device UDEV configuration..."

LVM_LOOPS_HOST_DEV=""

for param in $(cat /proc/cmdline); do
    case $param in
        lvm_loops_host_dev=*)
            LVM_LOOPS_HOST_DEV=${param#lvm_loops_host_dev=}
        ;;

    esac
done

if [ "${LVM_LOOPS_HOST_DEV}" = "" ]; then
  warn "One ore more arguments missing. Configuration skipped."
  exit 0
fi

cat > /etc/udev/rules.d/90-buddy-linux.rules << EOF
# http://www.reactivated.net/writing_udev_rules.html#ownership

ENV{ID_FS_UUID}=="${LVM_LOOPS_HOST_DEV}", RUN+="/sbin/initqueue --settled --onetime --name buddy-linux-setup /bin/bash /sbin/buddy-linux-setup.sh"
EOF
