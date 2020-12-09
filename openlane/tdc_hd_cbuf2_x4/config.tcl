# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) tdc_hd_cbuf2_x4
set macros [list "tapline_200_x4_cbuf2_hd"]

source $script_dir/../tdc-common/tdc-config.tcl

set ::env(FP_PIN_ORDER_CFG) $script_dir/../tdc_inline_3/pin_order.cfg

set ::env(FP_SIZING) absolute
set h [expr 160 * 2.72]
set ::env(DIE_AREA) "0 0 690 $h"

# Can change the cells!
#set ::env(PL_RESIZER_OVERBUFFER) 1
set ::env(PL_TARGET_DENSITY) 0.30

set ::env(DESIGN_IS_CORE) 0

# Too much memory
set ::env(RUN_SPEF_EXTRACTION) 0

set ::env(MAGIC_ZEROIZE_ORIGIN) 0

set x [expr 40 * 0.46]
set chan [open $script_dir/macro_placement.cfg w]

set y [expr 31.5 * 2.72]
puts $chan "inst_rtaps $x $y FS"
set y [expr 111.5 * 2.72]
puts $chan "inst_itaps $x $y N"

close $chan

# Align power
set ::env(FP_PDN_VOFFSET) [expr $x + 15.30]

set ::env(PDN_CFG) $script_dir/pdn.tcl
