# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

package require openlane

proc insert_diode {args} {
	puts_info " Insert diodes..."

	# Custom insertion script
	set ::env(SAVE_DEF) $::env(TMP_DIR)/placement/$::env(DESIGN_NAME).diodes.def
	try_catch python3 $::env(DESIGN_DIR)/../../tools/place_diodes.py -l $::env(MERGED_LEF) -id $::env(CURRENT_DEF) -o $::env(SAVE_DEF) |& tee $::env(TERMINAL_OUTPUT) $::env(LOG_DIR)/placement/diodes.log
	set_def $::env(SAVE_DEF)

	# Legalize
	detailed_placement
}


proc my_prep {args} {
	set options {
		{-design required}
	}
	set flags {}
	parse_key_args "my_flow" args arg_values $options flags_map $flags -no_consume

 	prep -tag user {*}$args
}

proc my_flow_route {args} {
	run_synthesis
	run_floorplan
	run_placement
    run_cts
    insert_diode
	gen_pdn
	run_routing
   if { $::env(LVS_INSERT_POWER_PINS) } {
		write_powered_verilog
		set_netlist $::env(lvs_result_file_tag).powered.v
    }

}

proc my_flow_gen_check {args} {
    puts "Current DEF is: $::env(CURRENT_DEF)"

 	run_magic

	run_magic_spice_export

	# Physical verification

	run_magic_drc

	run_lvs; # requires run_magic_spice_export

	run_antenna_check

	puts_success "Flow Completed Without Fatal Errors."
}

# This flow inserts diodes itself
set ::env(DIODE_INSERTION_STRATEGY) 0

my_prep {*}$argv -overwrite
my_flow_route

#my_prep {*}$argv
my_flow_gen_check
puts "Current DEF is: $::env(CURRENT_DEF)"
