# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

package require openlane; # provides the utils as well
set script_dir [file dirname [file normalize [info script]]]

set options {
    {-design required}
}
set flags {}
parse_key_args "build" argv arg_values $options flags_map $flags -no_consume

set ::env(DESIGN_NAME) $arg_values(-design)

prep {*}$argv -tag user -overwrite
set ::env(CURRENT_DEF) "$script_dir/../$::env(DESIGN_NAME)/$::env(DESIGN_NAME).def"
gen_pdn
run_routing
write_powered_verilog

run_magic
run_magic_spice_export
run_magic_drc

set ::env(CURRENT_NETLIST) "$script_dir/../$::env(DESIGN_NAME)/$::env(DESIGN_NAME).v"
run_lvs

run_antenna_check

