# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set ::env(FP_PIN_ORDER_CFG) $script_dir/../tdc-common/pin_order.cfg

set ::env(VERILOG_FILES) "$script_dir/../../src/$::env(DESIGN_NAME).v"
set ::env(VERILOG_FILES_BLACKBOX) "$script_dir/../../src/$::env(DESIGN_NAME)_bb.v"

#set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_PORT) "clk_i"
set ::env(CLOCK_NET) "clk_i"

set ::env(BASE_SDC_FILE) "$script_dir/../tdc-common/tdc.sdc"

# mgmt core uses 50, so we have a margin
set ::env(CLOCK_PERIOD) "20"

set ::env(PL_TARGET_DENSITY) 0.5

set ::env(DIODE_INSERTION_STRATEGY) 3
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 3

# Avoid weird optims
set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0

if { [llength $macros] != 0 } {
    set macros_lef ""
    set macros_gds ""
    foreach m $macros {
        set macros_lef "$macros_lef $script_dir/../../lef/$m.lef"
        set macros_gds "$macros_gds $script_dir/../../gds/$m.gds"
    }
    set ::env(EXTRA_LEFS)      "$macros_lef"
    set ::env(EXTRA_GDS_FILES) "$macros_gds"

    set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg
}
