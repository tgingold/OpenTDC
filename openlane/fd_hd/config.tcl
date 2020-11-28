# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_hd
set macros [list "delayline_9_hd"]

source $script_dir/../fd-common/fd-config.tcl

# area: 90*.46  120*2.72
set ::env(FP_SIZING) absolute
set x [expr 1186 * 0.46]
set ::env(DIE_AREA) "0 0 $x 231.2"

set ::env(PL_TARGET_DENSITY) 0.32

#set ::env(FILL_INSERTION) 0

#set ::env(PL_RESIZER_OVERBUFFER) 1

# Diode strategy:
# 2 -> creates LVS errors (as diodes and fakediodes mismatch)
set ::env(DIODE_INSERTION_STRATEGY) 3
#set ::env(RUN_SPEF_EXTRACTION) 0

# Macros
# macro VPWR: 6.410 8.010 -> y = 7.210
# prj   VPWR: 27290
set y 20.080
set chan [open $script_dir/macro_placement.cfg w]

set x [expr 340 * 0.46]
puts $chan "inst_tdelay_line $x $y N"
set x [expr 638 * 0.46]
puts $chan "inst_idelay_line $x $y N"
set x [expr 935 * 0.46]
puts $chan "inst_rdelay_line $x $y N"

close $chan

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

