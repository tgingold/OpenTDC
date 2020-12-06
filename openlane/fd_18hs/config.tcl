# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_18hs
set macros [list "delayline_9_osu_18hs"]

source $script_dir/../fd-common/fd-config.tcl

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 280 299"

set chan [open $script_dir/macro_placement.cfg w]

set x [expr 340 * 0.46]
puts $chan "inst_delay_line $x 18.81 N"
#set x [expr 628 * 0.46]
#puts $chan "inst_idelay_line $x 18.81 N"
#set x [expr 930 * 0.46]
#puts $chan "inst_rdelay_line $x 18.81 N"

close $chan

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

set ::env(PL_RESIZER_OVERBUFFER) 1
