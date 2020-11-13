package require openlane; # provides the utils as well
set script_dir [file dirname [file normalize [info script]]]

prep -design $::env(DESIGN_NAME) -tag user -overwrite
set ::env(CURRENT_DEF) "$script_dir/$::env(DESIGN_NAME).def"
gen_pdn
run_routing
run_magic
run_magic_drc
run_antenna_check
generate_final_summary_report
