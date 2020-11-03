# User config
set ::env(DESIGN_NAME) opentdc

# Source files
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/opentdc/src/*.v]

# Clock
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# Disable diode insertion
# set ::env(DIODE_INSERTION_STRATEGY) 0

# Source PDK specific settings
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
