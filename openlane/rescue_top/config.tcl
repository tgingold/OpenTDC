# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) rescue_top
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(VERILOG_FILES) "$script_dir/../../src/rescue_top.v"
set ::env(VERILOG_FILES_BLACKBOX) "$script_dir/../../src/$::env(DESIGN_NAME)_bb.v"

# mgmt core uses 50, so we have a margin
set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "clk_i"
set ::env(CLOCK_NET) "clk_i"

set ::env(FP_SIZING) absolute

set ::env(DESIGN_IS_CORE) 0

# The tricky part: we want to intersect with parent power straps
#set ::env(FP_PDN_VOFFSET) 16.32
#set ::env(FP_PDN_VPITCH) 153.6
#set ::env(FP_PDN_HOFFSET) 16.65
#set ::env(FP_PDN_HPITCH) 153.18
set ::env(DIE_AREA) "0 0 544.0 176.8"

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
