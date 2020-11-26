# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_hd
set macros [list "delayline_9_hd"]

source $script_dir/../fd-common/fd-config.tcl

# area: 90*.46  120*2.72
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 414 231.2"
set ::env(PL_TARGET_DENSITY) 0.4

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

set ::env(PL_RESIZER_OVERBUFFER) 1


#set chan [open my.log a]
#set timestamp [clock format [clock seconds]]
#puts $chan "$timestamp - Hello, World!"
#close $chan
