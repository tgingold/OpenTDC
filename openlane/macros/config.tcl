# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

# Clock (not used)
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# turn off CTS
set ::env(CLOCK_TREE_SYNTH) 0

# Disable diode insertion (not supported by fd_sc_hs)
set ::env(DIODE_INSERTION_STRATEGY) 0

# Use default hpitch.
#set ::env(FP_PDN_VOFFSET) 10.88
#set ::env(FP_PDN_VOFFSET) 0
#set ::env(FP_PDN_VPITCH) 16
#set ::env(FP_PDN_HOFFSET) 2.72
#set ::env(FP_PDN_HPITCH) 7.04
#set ::env(FP_TAPCELL_DIST) 14

#set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 32.660 38.080"

#set ::env(FP_CORE_UTIL) 50;
set ::env(PL_TARGET_DENSITY) 0.6

set ::env(GLB_RT_TILES) 8

#set ::env(GLB_RT_ADJUSTMENT) 0.1

# Add padding as there are not always pins on all sides
set ::env(MAGIC_PAD) 1
set ::env(PLACE_SITE_WIDTH) 4
set ::env(PLACE_SITE_HEIGHT) 4

set filename $::env(DESIGN_NAME)/$::env(DESIGN_NAME).tcl
puts "sourcing $filename"
source $filename

# Overwrite for caravel
set ::env(FP_PDN_VOFFSET) 0
set ::env(FP_PDN_VPITCH) 26.640
set ::env(FP_PDN_HOFFSET) 9.2
set ::env(FP_PDN_HPITCH) 180

set filename $::env(DESIGN_NAME)/config.tcl
if {[file exists $filename]} {
    puts "sourcing $filename"
    source $filename
}

