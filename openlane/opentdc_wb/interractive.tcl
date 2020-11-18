package require openlane; # provides the utils as well

prep -design opentdc_wb -tag user -overwrite

run_synthesis
run_floorplan
run_placement
run_cts
gen_pdn
run_routing
run_magic
run_magic_drc
