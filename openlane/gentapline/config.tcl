set script_dir [file dirname [file normalize [info script]]]

# User config
#set ::env(DESIGN_NAME) tapline

# Clock (not used)
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# turn off CTS
set ::env(CLOCK_TREE_SYNTH) 0

# Disable diode insertion
# set ::env(DIODE_INSERTION_STRATEGY) 0

# Use default hpitch.
set ::env(FP_PDN_VOFFSET) 10.88
set ::env(FP_PDN_VPITCH) 7.2
set ::env(FP_PDN_HOFFSET) 2.72
set ::env(FP_PDN_HPITCH) 153.18

#set ::env(FP_TAPCELL_DIST) 14

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 32.660 38.080"

#set ::env(FP_CORE_UTIL) 50;
set ::env(PL_TARGET_DENSITY) 0.6

set ::env(GLB_RT_TILES) 8

#set ::env(GLB_RT_ADJUSTMENT) 0.1
