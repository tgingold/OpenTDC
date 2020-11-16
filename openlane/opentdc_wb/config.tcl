# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(VERILOG_FILES) "$script_dir/user_project_wrapper.v $script_dir/../../src/opentdc.v"
set ::env(VERILOG_FILES_BLACKBOX) "$script_dir/../../src/bb.v"

#set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "wb_clk_i"

set ::env(CLOCK_PERIOD) "20"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 2700 2700"
set ::env(PL_TARGET_DENSITY) 0.3

set macros [list "tapline_200_x2_hd" "tapline_200_x2_hd_ref"]
set macros_lef ""
set macros_gds ""
foreach m $macros {
    set macros_lef "$macros_lef $script_dir/../../lef/$m.lef"
    set macros_gds "$macros_gds $script_dir/../../gds/$m.gds"
}
set ::env(EXTRA_LEFS)      "$macros_lef"
set ::env(EXTRA_GDS_FILES) "$macros_gds"
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg
