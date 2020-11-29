# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_hd_25_1
set macros [list "delayline_9_hd_25_1"]

source $script_dir/../fd-common/fd-config.tcl

# area: 90*.46  120*2.72
set ::env(FP_SIZING) absolute
set x [expr 1036 * 0.46]
set ::env(DIE_AREA) "0 0 $x 231.2"

set ::env(PL_TARGET_DENSITY) 0.32

#set ::env(FILL_INSERTION) 0

#set ::env(PL_RESIZER_OVERBUFFER) 1

# Diode strategy:
# 2 -> creates LVS errors (as diodes and fakediodes mismatch)
set ::env(DIODE_INSERTION_STRATEGY) 3
#set ::env(RUN_SPEF_EXTRACTION) 0

# Macros
set y [expr (33680 - 14400) / 1000]
set chan [open $script_dir/macro_placement.cfg w]

set x [expr 20 * 0.46]
puts $chan "inst_tdelay_line $x $y FN"
set x [expr 400 * 0.46]
puts $chan "inst_idelay_line $x $y N"
set x [expr 665 * 0.46]
puts $chan "inst_rdelay_line $x $y FN"

close $chan

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(FP_PDN_VPITCH) 26.64
set ::env(FP_PDN_HOFFSET) [expr 9.4 + 10.84 ]
