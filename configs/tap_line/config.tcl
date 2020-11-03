# User config
set ::env(DESIGN_NAME) tap_line

# Source files
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/tap_line/src/*.v]

set ::env(VERILOG_FILES_BLACKBOX) $::env(OPENLANE_ROOT)/designs/tap_line/src/bb.v

# Clock
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk_i"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# Disable diode insertion
# set ::env(DIODE_INSERTION_STRATEGY) 0

# Source PDK specific settings
set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
