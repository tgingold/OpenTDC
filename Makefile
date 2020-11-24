# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

CP=cp
GHDL_PLUGIN=ghdl.so
YOSYS=yosys

FD_MACROS=fd_hd fd_hs fd_ms fd_inline_1
MACROS=$(FD_MACROS)

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
grep -F "Circuits match uniquely." openlane/$$DESIGN/runs/user/results/lvs/$$DESIGN.lvs.log && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.gds gds && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.lef lef && \
cp openlane/$$DESIGN/runs/user/results/routing/$$DESIGN.def def
endef

define yosys_fd
DESIGN=$(notdir $(basename $@ .v)); $(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e $$DESIGN; write_verilog $@; write_verilog -blackboxes src/$${DESIGN}_bb.v"
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


# Fine delays

src/fd_hd.v: $(VHDL_COMMON_SRCS) rtl/openfd_core2.vhdl rtl/fd_hd.vhdl
	$(yosys_fd)

gds/fd_hd.gds lef/fd_hd.lef: src/fd_hd.v src/fd_hd_bb.v gds/delayline_9_hd.gds
	$(build-macro)

src/fd_hs.v: $(VHDL_COMMON_SRCS) rtl/openfd_core2.vhdl rtl/fd_hs.vhdl
	$(yosys_fd)

gds/fd_hs.gds lef/fd_hs.lef: src/fd_hs.v src/fd_hs_bb.v gds/delayline_9_hs.gds
	$(build-macro)


src/fd_ms.v: $(VHDL_COMMON_SRCS) rtl/openfd_core2.vhdl rtl/fd_ms.vhdl
	$(yosys_fd)

gds/fd_ms.gds lef/fd_ms.lef: src/fd_ms.v src/fd_ms_bb.v gds/delayline_9_ms.gds
	$(build-macro)


src/fd_inline_1.v: $(VHDL_COMMON_SRCS) rtl/openfd_core2.vhdl rtl/openfd_delayline.vhdl rtl/fd_inline.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -gcell=1 $^ -e fd_inline; rename fd_inline fd_inline_1; write_verilog $@; write_verilog -blackboxes src/fd_inline_1_bb.v"

gds/fd_inline_1.gds lef/fd_inline_1.lef: src/fd_inline_1.v src/fd_inline_1_bb.v
	$(build-macro)


openlane/macros/delayline_9_ms.def:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_ms -l 9 -t fd_ms -d dly4_1

gds/delayline_9_ms.gds: openlane/macros/delayline_9_ms.def
	cd openlane/macros; ./openlane-all.sh $(notdir $<)


openlane/macros/delayline_9_hs.def:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_hs -l 9 -t fd_hs -d dly4_1

gds/delayline_9_hs.gds: openlane/macros/delayline_9_hs.def
	cd openlane/macros; ./openlane-all.sh $(notdir $<)


openlane/macros/delayline_9_hd.def:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_hd -l 9

gds/delayline_9_hd.gds: openlane/macros/delayline_9_hd.def
	cd openlane/macros; ./openlane-all.sh $(notdir $<)




verilog: $(foreach v,$(MACROS),src/$(v).v)

synth-tapline:
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -glength=2 rtl/opentdc_delay.vhdl rtl/opentdc_delay-sky130.vhdl rtl/tap_line.vhdl -e; flatten; clean; chtype -map sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog src/tap_line.v; rename sky130_delay sky130_fd_sc_hd__clkdlybuf4s15_1; write_verilog -blackboxes src/bb.v"

uncompress:

compress:

verify:


