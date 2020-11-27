# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_hs
set macros [list "delayline_9_hs"]

source $script_dir/../fd-common/fd-config.tcl

# area: 90*.46  120*2.72
set ::env(FP_SIZING) absolute
set x [expr 1110 * 0.46]
set ::env(DIE_AREA) "0 0 $x 280.2"

set ::env(PL_RESIZER_OVERBUFFER) 1

# Macros
# 9_hs VPWR: 7.680-9.280 -> y = 8.480
# prj  VPWR: 27290
# -> y = 18810
set chan [open $script_dir/macro_placement.cfg w]

set x [expr 200 * 0.46]
puts $chan "inst_tdelay_line $x 18.81 N"
set x [expr 478 * 0.46]
puts $chan "inst_idelay_line $x 18.81 N"
set x [expr 835 * 0.46]
puts $chan "inst_rdelay_line $x 18.81 N"

close $chan

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg
