# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_hd
set macros [list "delayline_9_hd"]

source $script_dir/../fd-common/fd-config.tcl

# area: 90*.46  120*2.72
set ::env(FP_SIZING) absolute
set x [expr 1200 * 0.46]
set ::env(DIE_AREA) "0 0 $x 231.2"
set ::env(PL_TARGET_DENSITY) 0.4

set ::env(PL_RESIZER_OVERBUFFER) 1


# Macros
# 9_hd VPWR: 7.680-9.280 -> y = 8.010
# prj  VPWR: 27290
# -> y = 19980
set chan [open $script_dir/macro_placement.cfg w]

set x [expr 340 * 0.46]
puts $chan "inst_tdelay_line $x 19.98 N"
set x [expr 638 * 0.46]
puts $chan "inst_idelay_line $x 19.98 N"
set x [expr 935 * 0.46]
puts $chan "inst_rdelay_line $x 19.98 N"

close $chan

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

