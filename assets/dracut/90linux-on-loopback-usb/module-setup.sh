#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
  return 0
}

depends() {
  echo base lvm
  return 0
}

install() {
  SETUP_SCRIPT=linux-on-loopback-usb-setup.sh
  inst_script "${moddir}/${SETUP_SCRIPT}" /sbin/${SETUP_SCRIPT}

  inst_hook cmdline 90 "${moddir}/linux-on-loopback-usb-cmdline.sh"
  inst_hook pre-pivot 90 "${moddir}/linux-on-loopback-usb-pre-pivot.sh"
  inst_hook shutdown 20 "${moddir}/linux-on-loopback-usb-shutdown.sh" # Priority 30 to run before DM shutdown (priority 30).
}
