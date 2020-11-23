# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

CP=cp
GHDL_PLUGIN=ghdl.so
YOSYS=yosys

VHDL_COMMON_SRCS=\
 rtl/opentdc_delay.vhdl \
 rtl/opentdc_delay-sky130.vhdl \
 rtl/opentdc_pkg.vhdl \
 openlane/macros/opentdc_comps.vhdl

VHDL_SRCS= $(VHDL_COMMON_SRCS) \
 rtl/opentdc_sync.vhdl \
 rtl/opentdc_tapline.vhdl \
 rtl/opentdc_time.vhdl \
 rtl/opentdc_core2.vhdl \
 rtl/openfd_delayline.vhdl \
 rtl/openfd_core2.vhdl \
 rtl/opentdc_wb.vhdl

define build-macro
DESIGN=$(basename $(notdir $<) .v) && echo "Building $$DESIGN" && \
(cd openlane; /openLANE_flow/openlane/flow.tcl -design $$DESIGN -tag user -overwrite) && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.gds gds && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.lef lef && \
cp openlane/$$DESIGN/runs/user/results/routing/$$DESIGN.def def
endef

# Create macros: generate the sources and gds
macros:
	cd openlane/macros; ./build-src.sh && ./openlane-all.sh

clean:
	$(RM) -f gds/*.gds lef/*.lef def/*.def mag/*.mag

# Create gds from verilog sources + macros
build:
	cd openlane; /openLANE_flow/openlane/flow.tcl -design opentdc_wb -tag user -overwrite

ibuild:
	cd openlane; /openLANE_flow/openlane/flow.tcl -it -file opentdc_wb/interractive.tcl

opentdc-report.html: openlane/opentdc_wb/runs/user/reports/final_summary_report.csv
	 python3 /openLANE_flow/openlane/scripts/csv2html/csv2html.py -i $< -o $@

src/opentdc.v: $(VHDL_SRCS)
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $(VHDL_SRCS) -e; write_verilog $@; write_verilog -blackboxes src/bb.v"

src/fd2.v: $(VHDL_COMMON_SRCS) rtl/openfd_core2.vhdl rtl/fd2.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e fd2; write_verilog $@; write_verilog -blackboxes src/fd2_bb.v"

gds/fd2.gds lef/fd2.lef &: src/fd2.v src/fd2_bb.v
	$(build-macro)

src/fd1.v: $(VHDL_COMMON_SRCS) rtl/openfd_core2.vhdl rtl/fd1.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e fd1; write_verilog $@; write_verilog -blackboxes src/fd1_bb.v"

gds/fd1.gds lef/fd1.lef: src/fd1.v src/fd1_bb.v
	$(build-macro)

verilog: src/opentdc.v

synth-tapline:
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -glength=2 rtl/opentdc_delay.vhdl rtl/opentdc_delay-sky130.vhdl rtl/tap_line.vhdl -e; flatten; clean; chtype -map sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog src/tap_line.v; rename sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog -blackboxes src/bb.v"

uncompress:

compress:

verify:


