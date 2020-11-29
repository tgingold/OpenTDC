# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) tdc_inline_3
set macros [list]

source $script_dir/../tdc-common/tdc-config.tcl

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(FP_SIZING) absolute
# y=2.72 * 150
set ::env(DIE_AREA) "0 0 460 408"

# Can change the cells!
#set ::env(PL_RESIZER_OVERBUFFER) 1
set ::env(PL_TARGET_DENSITY) 0.35

set ::env(DESIGN_IS_CORE) 0

set ::env(DIODE_INSERTION_STRATEGY) 3

# Too much memory
set ::env(RUN_SPEF_EXTRACTION) 0
