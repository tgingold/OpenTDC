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


# antenna:
# runs/user/logs/routing/or_antenna.log
# runs/user/reports/routing/antenna.rpt

# STA:
# runs/user/reports/synthesis/opensta_spef.timing.rpt

# DRC:
# runs/user/logs/magic/magic.drc

