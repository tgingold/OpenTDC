# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-License-Identifier: Apache-2.0

CP=cp
MKDIR=mkdir
GHDL_PLUGIN=ghdl.so
YOSYS=yosys

HARD_MACROS=delayline_9_hd delayline_9_hs delayline_9_ms delayline_9_hd_25_1 delayline_9_osu_18hs

FD_MACROS=fd_hd fd_hs fd_ms fd_hd_25_1 fd_inline_1
TDC_MACROS=tdc_inline_1 tdc_inline_2 tdc_inline_3
MACROS=wb_extender wb_interface rescue_top zero $(FD_MACROS) $(TDC_MACROS)

VHDL_COMMON_SRCS=\
 rtl/opentdc_delay.vhdl \
 rtl/opentdc_delay-sky130.vhdl \
 rtl/opentdc_pkg.vhdl \
 rtl/counter.vhdl \
 rtl/opendelay_comps.vhdl

VHDL_TAPLINE_SRCS=\
 rtl/opentdc_sync.vhdl \
 rtl/opentdc_tapline.vhdl

VHDL_TDC_EXTRA_SRCS=\
 $(VHDL_TAPLINE_SRCS) \
 rtl/opentdc_time.vhdl \
 rtl/opentdc_core2.vhdl

VHDL_FD_EXTRA_SRCS=\
 rtl/openfd_delayline.vhdl \
 rtl/openfd_core2.vhdl

VHDL_SRCS= $(VHDL_COMMON_SRCS) \
 $(VHDL_TDC_EXTRA_SRCS) \
 $(VHDL_FD_EXTRA_SRCS) \
 rtl/openfd_comps.vhdl \
 rtl/opentdc_comps.vhdl \
 rtl/opentdc_wb.vhdl

define build-status
echo "Status $$DESIGN" && \
grep -F "Circuits match uniquely." openlane/$$DESIGN/runs/user/results/lvs/$$DESIGN.lvs.log ; \
grep -F COUNT openlane/$$DESIGN/runs/user/logs/magic/magic.drc.log && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.gds gds/ && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.lef lef/ && \
cp openlane/$$DESIGN/runs/user/results/magic/$$DESIGN.mag mag/ && \
cp openlane/$$DESIGN/runs/user/results/routing/$$DESIGN.def def/ && \
cp openlane/$$DESIGN/runs/user/results/lvs/$$DESIGN.lvs.powered.v verilog/gl/$$DESIGN.v
endef

define build-script
DESIGN=$(basename $(notdir $<) .v) && echo "Building $$DESIGN" && \
(cd openlane; /openLANE_flow/openlane/flow.tcl -it -file $$DESIGN/interactive.tcl ) && \
$(build-status)
endef

define build-flow
DESIGN=$(basename $(notdir $<) .v) && echo "Building $$DESIGN" && \
(cd openlane; /openLANE_flow/openlane/flow.tcl -it -file my_flow.tcl -design $$DESIGN) && \
$(build-status)
endef

define fix-lef
DESIGN=$(basename $(notdir $<) .v) && echo "Fixing LEF $$DESIGN" && \
cd lef; ./fix-lef.sh $$DESIGN.lef
endef

define build-macro
DESIGN=$(basename $(notdir $<) .def) && echo "Building $$DESIGN" && \
(cd openlane; /openLANE_flow/openlane/flow.tcl -it -file macros/build.tcl -design $$DESIGN -config_file macros/config.tcl) && \
$(build-status)
endef

define yosys_fd
DESIGN=$(notdir $(basename $@ .v)); $(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e $$DESIGN; write_verilog $@; write_verilog -blackboxes src/$${DESIGN}_bb.v"
endef

all: gds/user_project_wrapper.gds

# Create macros: generate the sources and gds
macros: $(foreach m,$(HARD_MACROS),gds/$(m).gds)


# Project

gds/user_project_wrapper.gds: src/user_project_wrapper.v openlane/user_project_wrapper/macros.tcl $(foreach m,$(MACROS),gds/$(m).gds)
	$(build-script)

src/user_project_wrapper.v: rtl/user_project_wrapper.vhdl rtl/opentdc_pkg.vhdl rtl/openfd_comps.vhdl rtl/opentdc_comps.vhdl
	$(yosys_fd)
#	$(YOSYS) -p "read_verilog $^; hierarchy -top user_project_wrapper; flatten; opt_clean -purge; splitnets; write_verilog -noattr $@"

openlane/user_project_wrapper/macros.tcl: Makefile
	echo 'set macros [list $(foreach n,$(MACROS),"$(n)")]' > $@

# Delay lines

openlane/delayline_9_ms/delayline_9_ms.def openlane/delayline_9_ms/delayline_9_ms_comp.vhdl:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_ms -l 9 -t fd_ms -d dly4_1

gds/delayline_9_ms.gds: openlane/delayline_9_ms/delayline_9_ms.def
	$(build-macro)


openlane/delayline_9_hs/delayline_9_hs.def openlane/delayline_9_hs/delayline_9_hs_comp.vhdl:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_hs -l 9 -t fd_hs -d dly4_1

gds/delayline_9_hs.gds: openlane/delayline_9_hs/delayline_9_hs.def
	$(build-macro)


openlane/delayline_9_hd/delayline_9_hd.def openlane/delayline_9_hd/delayline_9_hd_comp.vhdl:
# Note: OK: cdly15_2, cdly25_1
#       KO: cdly15_1, cdly18_1
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_hd -l 9 -d cdly15_2

gds/delayline_9_hd.gds: openlane/delayline_9_hd/delayline_9_hd.def
	$(build-macro)


openlane/delayline_9_hd_25_1/delayline_9_hd_25_1.def openlane/delayline_9_hd_25_1/delayline_9_hd_25_1_comp.vhdl:
	$(MKDIR) -p $(dir $@)
# Note: OK: cdly15_2, cdly25_1
#       KO: cdly15_1, cdly18_1
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_hd_25_1 -l 9 -d cdly25_1

gds/delayline_9_hd_25_1.gds: openlane/delayline_9_hd_25_1/delayline_9_hd_25_1.def
	$(build-macro)


openlane/delayline_9_osu_18hs/delayline_9_osu_18hs.def:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_delayline.py -n delayline_9_osu_18hs -l 9 --tech osu_18T_hs --delay buf_1

gds/delayline_9_osu_18hs.gds: openlane/delayline_9_osu_18hs/delayline_9_osu_18hs.def
	$(build-macro)


rtl/opendelay_comps.vhdl: Makefile $(foreach x,$(HARD_MACROS),openlane/$(x)/$(x)_comp.vhdl)
	{ \
	echo "library ieee;"; \
	echo "use ieee.std_logic_1164.all;"; \
	echo; \
	echo "package opendelay_comps is"; \
	for M in $(HARD_MACROS); do \
	cat openlane/$${M}/$${M}_comp.vhdl; \
	echo; \
	done; \
	echo "end opendelay_comps;"; \
	} > $@

# Tap lines (experimental)

openlane/tapline_200_x4_cbuf2_hd/tapline_200_x4_cbuf2_hd.def openlane/tapline_200_x4_cbuf2_hd/tapline_200_x4_cbuf2_hd.vhdl:
	$(MKDIR) -p $(dir $@)
	cd $(dir $@); ../../tools/gen_tapline.py -n tapline_200_x4_cbuf2_hd -l 200 -g 4 -c s1 -d cbuf_2 -t fd_hd

gds/tapline_200_x4_cbuf2_hd.gds: openlane/tapline_200_x4_cbuf2_hd/tapline_200_x4_cbuf2_hd.def
	$(build-macro)


# Fine delays

src/fd_hd.v: $(VHDL_COMMON_SRCS) $(VHDL_TAPLINE_SRCS) rtl/openfd_core2.vhdl rtl/fd_hd.vhdl
	$(yosys_fd)

gds/fd_hd.gds lef/fd_hd.lef: src/fd_hd.v src/fd_hd_bb.v gds/delayline_9_hd.gds
	$(build-flow)


src/fd_hs.v: $(VHDL_COMMON_SRCS) $(VHDL_TAPLINE_SRCS) rtl/openfd_core2.vhdl rtl/fd_hs.vhdl
	$(yosys_fd)

gds/fd_hs.gds lef/fd_hs.lef: src/fd_hs.v src/fd_hs_bb.v gds/delayline_9_hs.gds
	$(build-flow)


src/fd_ms.v: $(VHDL_COMMON_SRCS) $(VHDL_TAPLINE_SRCS) rtl/openfd_core2.vhdl rtl/fd_ms.vhdl
	$(yosys_fd)

gds/fd_ms.gds lef/fd_ms.lef: src/fd_ms.v src/fd_ms_bb.v gds/delayline_9_ms.gds
	$(build-flow)


src/fd_hd_25_1.v: $(VHDL_COMMON_SRCS) $(VHDL_TAPLINE_SRCS) rtl/openfd_core2.vhdl rtl/fd_hd_25_1.vhdl
	$(yosys_fd)

gds/fd_hd_25_1.gds lef/fd_hd_25_1.lef: src/fd_hd_25_1.v src/fd_hd_25_1_bb.v gds/delayline_9_hd_25_1.gds
	$(build-flow)


src/fd_18hs.v: $(VHDL_COMMON_SRCS) $(VHDL_TAPLINE_SRCS) rtl/openfd_core2.vhdl rtl/fd_18hs.vhdl
	$(yosys_fd)

gds/fd_18hs.gds lef/fd_18hs.lef: src/fd_18hs.v src/fd_18hs_bb.v gds/delayline_9_osu_18hs.gds
	$(build-flow)


src/fd_inline_1.v: $(VHDL_COMMON_SRCS) rtl/opentdc_sync.vhdl rtl/opentdc_tapline.vhdl rtl/openfd_core2.vhdl rtl/openfd_delayline.vhdl rtl/fd_inline.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -gcell=1 $^ -e fd_inline; rename fd_inline fd_inline_1; write_verilog $@; write_verilog -blackboxes src/fd_inline_1_bb.v"

gds/fd_inline_1.gds lef/fd_inline_1.lef: src/fd_inline_1.v src/fd_inline_1_bb.v
	$(build-flow)
	$(fix-lef)

rtl/openfd_comps.vhdl: Makefile
	{ \
	echo "library ieee;"; \
	echo "use ieee.std_logic_1164.all;"; \
	echo "use work.opentdc_pkg.all;"; \
	echo; \
	echo "package openfd_comps is"; \
	for M in $(FD_MACROS); do \
	echo "  component $$M is"; \
	echo "    port ("; \
	echo "      clk_i : std_logic;"; \
	echo "      rst_n_i : std_logic;"; \
	echo "      bus_in : dev_bus_in;"; \
	echo "      bus_out : out dev_bus_out;"; \
	case $$M in \
	 fd_hd_25_1|fd_inline_1) \
	              echo "      out_o : out std_logic);";; \
	 *)           echo "      out1_o : out std_logic;"; \
	              echo "      out2_o : out std_logic);"; \
	esac; \
	echo "  end component $$M;"; \
	echo; \
	done; \
	echo "end openfd_comps;"; \
	} > $@


# TDC
src/tdc_inline_1.v: $(VHDL_COMMON_SRCS) $(VHDL_TDC_EXTRA_SRCS) rtl/tdc_inline.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -gcell=1 $^ -e tdc_inline; rename tdc_inline tdc_inline_1; write_verilog $@; write_verilog -blackboxes src/tdc_inline_1_bb.v"

gds/tdc_inline_1.gds lef/tdc_inline_1.lef: src/tdc_inline_1.v src/tdc_inline_1_bb.v
	$(build-flow)
	$(fix-lef)

src/tdc_inline_2.v: $(VHDL_COMMON_SRCS) $(VHDL_TDC_EXTRA_SRCS) rtl/tdc_inline.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -gcell=3 $^ -e tdc_inline; rename tdc_inline tdc_inline_2; write_verilog $@; write_verilog -blackboxes src/tdc_inline_2_bb.v"

gds/tdc_inline_2.gds lef/tdc_inline_2.lef: src/tdc_inline_2.v src/tdc_inline_2_bb.v
	$(build-flow)
	$(fix-lef)

src/tdc_inline_3.v: $(VHDL_COMMON_SRCS) $(VHDL_TDC_EXTRA_SRCS) rtl/tdc_inline.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl -gcell=4 $^ -e tdc_inline; rename tdc_inline tdc_inline_3; write_verilog $@; write_verilog -blackboxes src/tdc_inline_3_bb.v"

gds/tdc_inline_3.gds lef/tdc_inline_3.lef: src/tdc_inline_3.v src/tdc_inline_3_bb.v
	$(build-flow)
	$(fix-lef)


rtl/opentdc_comps.vhdl: Makefile
	{ \
	echo "library ieee;"; \
	echo "use ieee.std_logic_1164.all;"; \
	echo "use work.opentdc_pkg.all;"; \
	echo; \
	echo "package opentdc_comps is"; \
	for M in $(TDC_MACROS); do \
	echo "  component $$M is"; \
	echo "    port ("; \
	echo "      clk_i : std_logic;"; \
	echo "      rst_n_i : std_logic;"; \
	echo "      bus_in : dev_bus_in;"; \
	echo "      bus_out : out dev_bus_out;"; \
	echo "      inp_i : std_logic);"; \
	echo "  end component $$M;"; \
	echo; \
	done; \
	echo "end opentdc_comps;"; \
	} > $@


# WB interface

src/wb_interface.v: $(VHDL_COMMON_SRCS) $(VHDL_TDC_EXTRA_SRCS) $(VHDL_FD_EXTRA_SRCS) rtl/wb_interface.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e wb_interface; write_verilog $@; write_verilog -blackboxes src/wb_interface_bb.v"

gds/wb_interface.gds lef/wb_interface.lef: src/wb_interface.v src/wb_interface_bb.v
	$(build-flow)
	$(fix-lef)

# WB extender

src/wb_extender_last.v: rtl/opentdc_pkg.vhdl rtl/wb_extender.vhdl rtl/wb_extender_last.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e wb_extender_last; write_verilog $@"

gds/wb_extender_last.gds lef/wb_extender_last.lef: src/wb_extender_last.v
	$(build-flow)


src/wb_extender.v: rtl/opentdc_pkg.vhdl rtl/wb_extender.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e wb_extender; write_verilog $@"

gds/wb_extender.gds lef/wb_extender.lef: src/wb_extender.v
	$(build-flow)
	$(fix-lef)


# Zero

src/zero.v: rtl/zero.v
	$(CP) $< $@

gds/zero.gds lef/zero.lef: rtl/zero.v
	$(build-script)


# Rescue

src/rescue_top.v: $(VHDL_COMMON_SRCS) $(VHDL_TDC_EXTRA_SRCS) $(VHDL_FD_EXTRA_SRCS) rtl/rescue.vhdl rtl/rescue_top.vhdl
	$(YOSYS) -m $(GHDL_PLUGIN) -p "ghdl $^ -e rescue_top; write_verilog $@; write_verilog -blackboxes src/rescue_top_bb.v"

gds/rescue_top.gds lef/rescue_top.lef: src/rescue_top.v src/rescue_top_bb.v
	$(build-flow)
	$(fix-lef)

#  Source generation

verilog: $(foreach v,$(MACROS),src/$(v).v) src/user_project_wrapper.v

add-spdx-src:
	for f in src/*.v verilog/gl/*.v ; do if ! grep -q SPDX $$f ; then \
	 (echo '//SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>'; \
	 echo '//SPDX-License-Identifier: Apache-2.0'; \
	 cat $$f ) > $$f.tmp; mv $$f.tmp $$f; \
	fi; done

# Aboard

ship: gds/caravel.gds

gds/caravel.gds: # gds/user_project_wrapper.gds
	if [ "$(CARAVEL)" = "" ]; then echo "Define CARAVEL!"; exit 1; fi
	if [ "$(PDK_ROOT)" = "" ]; then echo "Define PDK_ROOT!"; exit 1; fi
	cp gds/user_project_wrapper.gds $(CARAVEL)/gds
	cd $(CARAVEL); make ship PDK_ROOT=$(PDK_ROOT)
	cp $(CARAVEL)/gds/caravel.gds $@
	mkdir -p mag
	cp $(CARAVEL)/mag/caravel.mag mag/caravel.mag

CARAVEL_OUT=gpio_control_block simple_por storage mgmt_core user_id_programming mgmt_protect DFFRAM digital_pll mgmt_protect_hv chip_io
CARAVEL_EXTRA_MAG=\
 sky130_fd_pr__cap_mim_m3_1_WRT4AW.mag \
 sky130_fd_pr__cap_mim_m3_2_W5U4AW.mag \
 sky130_fd_pr__nfet_g5v0d10v5_PKVMTM.mag \
 sky130_fd_pr__nfet_g5v0d10v5_TGFUGS.mag \
 sky130_fd_pr__nfet_g5v0d10v5_ZK8HQC.mag \
 sky130_fd_pr__pfet_g5v0d10v5_3YBPVB.mag \
 sky130_fd_pr__pfet_g5v0d10v5_YEUEBV.mag \
 sky130_fd_pr__pfet_g5v0d10v5_YUHPBG.mag \
 sky130_fd_pr__pfet_g5v0d10v5_YUHPXE.mag \
 sky130_fd_pr__pfet_g5v0d10v5_ZEUEFZ.mag \
 sky130_fd_pr__res_xhigh_po_0p69_S5N9F3.mag \
 sky130_fd_sc_hvl__lsbufhv2lv_1_wrapped.mag \
 sram_1rw1r_32_256_8_sky130.mag

import-caravel:
	cp $(CARAVEL)/verilog/gl/caravel.v verilog/gl
	cp $(foreach f,$(CARAVEL_OUT),$(CARAVEL)/verilog/gl/$(f).v) verilog/gl
	cp $(foreach f,$(CARAVEL_OUT),$(CARAVEL)/mag/$(f).mag) mag/
	cp $(foreach f,$(CARAVEL_EXTRA_MAG),$(CARAVEL)/mag/$(f)) mag/

export-caravel:
	cp verilog/gl/*.v* $(CARAVEL)/verilog/gl/
	cp mag/*.mag* $(CARAVEL)/mag/
	cp lef/*.lef* $(CARAVEL)/lef/
	cp def/*.def* $(CARAVEL)/def/
	cp gds/*.gds* $(CARAVEL)/gds/

# Compress for github.

uncompress:
	gunzip gds/*.gds.gz def/*.def.gz lef/*.lef.gz mag/*.mag.gz verilog/gl/*.v.gz

compress:
	gzip -9 gds/*.gds def/*.def lef/*.lef verilog/gl/*.v

verify:
#	At some point, this should be automatic.  But we are not yet there.
	echo "Tests are in tb/ and tests/"

clean:
	$(RM) -f gds/*.gds* lef/*.lef* def/*.def* mag/*.mag* verilog/gl/*.v*

