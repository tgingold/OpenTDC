package require openlane; # provides the utils as well

# Disable LVS for now
set ::env(LEC_ENABLE) 0
set ::env(LVS_INSERT_POWER_PINS) 0

prep -design opentdc_wb -tag user -overwrite

run_synthesis
run_floorplan
run_placement
run_cts
gen_pdn
run_routing
run_magic
run_magic_drc
