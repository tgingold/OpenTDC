# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) zero
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(VERILOG_FILES) "$script_dir/../../rtl/zero.v"

# mgmt core uses 50, so we have a margin
set ::env(CLOCK_PERIOD) "20"

set ::env(FP_SIZING) absolute

set ::env(DESIGN_IS_CORE) 0

# The tricky part: we want to intersect with parent power straps
#set ::env(FP_PDN_VOFFSET) 16.32
#set ::env(FP_PDN_VPITCH) 153.6
#set ::env(FP_PDN_HOFFSET) 16.65
#set ::env(FP_PDN_HPITCH) 153.18
set ::env(DIE_AREA) "0 0 54.4 176.8"

# The perfect case
set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0

set y 57.120
set chan [open $script_dir/macro_placement.cfg w]

set x [expr 44 * 0.46]
puts $chan "LEFT1 $x $y N"
set x [expr $x + 4 * 0.46]
puts $chan "LEFT2 $x $y N"
set x [expr $x + 4 * 0.46]
puts $chan "ZEROA $x $y N"
set x [expr $x + 3 * 0.46]
puts $chan "RIGHT1 $x $y N"
set x [expr $x + 4 * 0.46]
puts $chan "RIGHT2 $x $y N"

close $chan

# The other tricky part: conb_1 is not compatible with decap_ cells.
#set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg

# Unused but needed for triggering macro placement
# set ::env(EXTRA_LEFS) "$script_dir/../../lef/delayline_9_hd.lef"
