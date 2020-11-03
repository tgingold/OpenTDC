GHDL_PLUGIN=${GHDL_PLUGIN:-ghdl.so}

#yosys -m $GHDL_PLUGIN -p "ghdl rtl/opentdc_delay.vhdl rtl/opentdc_delay-sim.vhdl rtl/opentdc_core.vhdl rtl/opentdc.vhdl -e; write_verilog opentdc.v"

# For tap_line
# Put results in src/
# Rename the sky130_delay instance and module
# Write the modules and the blackboxes.
yosys -m $GHDL_PLUGIN -p "ghdl -glength=90 rtl/opentdc_delay.vhdl rtl/opentdc_delay-sky130.vhdl rtl/tap_line.vhdl -e; chtype -map sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog src/tap_line.v; rename sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog -blackboxes src/bb.v"

# For opentdc
yosys -m $GHDL_PLUGIN -p "ghdl rtl/opentdc_delay.vhdl rtl/opentdc_delay-sky130.vhdl rtl/opentdc_core.vhdl rtl/opentdc.vhdl -e; chtype -map sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog src/opentdc.v; rename sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog -blackboxes src/bb.v"