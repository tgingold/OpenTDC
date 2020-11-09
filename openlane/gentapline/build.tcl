package require openlane; # provides the utils as well
set script_dir [file dirname [file normalize [info script]]]

prep -design gentapline -tag user -overwrite
set ::env(CURRENT_DEF) $script_dir/tapline.placed.def
gen_pdn
run_routing
run_magic
run_magic_drc
run_antenna_check
generate_final_summary_report
