# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) fd_hd
set macros [list "delayline_9_hd"]

source $script_dir/../fd-common/fd-config.tcl

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 280 280"

set ::env(MACRO_PLACEMENT_CFG) $script_dir/macro_placement.cfg
