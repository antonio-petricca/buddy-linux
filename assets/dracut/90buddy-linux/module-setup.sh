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
  SETUP_SCRIPT=buddy-linux-setup.sh
  inst_script "${moddir}/${SETUP_SCRIPT}" /sbin/${SETUP_SCRIPT}

  inst_hook cmdline 90 "${moddir}/buddy-linux-cmdline.sh"
  inst_hook pre-pivot 90 "${moddir}/buddy-linux-pre-pivot.sh"
  inst_hook shutdown 20 "${moddir}/buddy-linux-shutdown.sh" # Priority 30 to run before DM shutdown (priority 30).
}
