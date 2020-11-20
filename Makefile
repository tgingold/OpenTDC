# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

CP=cp
GHDL_PLUGIN=ghdl.so
YOSYS=yosys

VHDL_SRCS=\
 rtl/opentdc_delay.vhdl \
 rtl/opentdc_delay-sky130.vhdl \
 rtl/opentdc_sync.vhdl \
 rtl/opentdc_tapline.vhdl \
 rtl/opentdc_pkg.vhdl \
 rtl/opentdc_time.vhdl \
 rtl/opentdc_core2.vhdl \
 rtl/openfd_delayline.vhdl \
 rtl/openfd_core2.vhdl \
 openlane/macros/opentdc_comps.vhdl \
 rtl/opentdc_wb.vhdl

build:
	cd openlane; /openLANE_flow/openlane/flow.tcl -design opentdc_wb -tag user -overwrite

ibuild:
	cd openlane; /openLANE_flow/openlane/flow.tcl -it -file opentdc_wb/interractive.tcl

src/opentdc.v: $(VHDL_SRCS)
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $(VHDL_SRCS) -e; write_verilog src/opentdc.v; write_verilog -blackboxes src/bb.v"

verilog: src/opentdc.v

synth-tapline:
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -glength=2 rtl/opentdc_delay.vhdl rtl/opentdc_delay-sky130.vhdl rtl/tap_line.vhdl -e; flatten; clean; chtype -map sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog src/tap_line.v; rename sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog -blackboxes src/bb.v"

uncompress:

compress:

verify:

clean:

