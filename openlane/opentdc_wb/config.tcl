set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) opentdc_wb
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(VERILOG_FILES) "$script_dir/../../src/opentdc.v"
set ::env(VERILOG_FILES_BLACKBOX) "$script_dir/../../src/bb.v"

#set ::env(CLOCK_PORT) "user_clock2"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "wb_clk_i"

set ::env(CLOCK_PERIOD) "20"

set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 2700 2700"
set ::env(DIE_AREA) "0 0 1000 1000"
set ::env(PL_TARGET_DENSITY) 0.5

set ::env(EXTRA_LEFS)      "$script_dir/macros/tapline_20.lef"
set ::env(EXTRA_GDS_FILES) "$script_dir/macros/tapline_20.gds"
set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg
