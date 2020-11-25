# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) tdc_inline_1
set macros [list]

source $script_dir/../tdc-common/tdc-config.tcl

# x = X * .460; y = Y * 2.72
set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 828 380"
set ::env(DIE_AREA) "0 0 414 408"

set ::env(PL_RESIZER_OVERBUFFER) 1
set ::env(PL_TARGET_DENSITY) 0.4
