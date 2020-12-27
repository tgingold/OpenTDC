# SPDX-FileCopyrightText: (c) 2020 Tristan Gingold <tgingold@free.fr>
# SPDX-FileCopyrightText: (Based on caravel file by efabless)
# SPDX-License-Identifier: Apache-2.0

CARAVEL=../../caravel_OpenTDC
CROSS=riscv32-elf-

FIRMWARE_PATH=$(CARAVEL)/verilog/dv/caravel

CC=$(CROSS)gcc

all: main.hex

RTL_PATH = ../../../../rtl
IP_PATH = ../../../../ip
BEHAVIOURAL_MODELS = ../../ 

.SUFFIXES:

functional/blackbox.v: ../src/user_project_wrapper_bb.v
#  Just keep the minimum (to speed up simulation)
	sed -e '/blackbox/d' -e '/module wb_interface/,/endmodule/d' \
	  -e '/module zero/,/endmodule/d' < $< > $@

functional.vvp: main_tb.v main.hex functional/blackbox.v
	iverilog -g2005 -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-Ifunctional/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

functional.i: main_tb.v main.hex functional/blackbox.v
	iverilog -E -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-Ifunctional/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

functional.out: functional.vvp
	vvp $< | tee $@

gl.vvp: main_tb.v main.hex gl/wb_interface.simple.v gl/wb_extender.simple.v gl/fd_hd.simple.v gl/delayline_9_hd.simple.v gl/tdc_inline_1.simple.v gl/tdc_inline_2.simple.v gl/tdc_inline_3.simple.v gl/fd_hs.simple.v gl/delayline_9_hs.simple.v gl/fd_ms.simple.v gl/delayline_9_ms.simple.v gl/fd_inline_1.simple.v gl/fd_hd_25_1.simple.v gl/delayline_9_hd_25_1.simple.v gl/tdc_hd_cbuf2_x4.simple.v gl/tapline_200_x4_cbuf2_hd.simple.v gl/rescue_top.simple.v
	iverilog -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-DWRAPPER_USE_POWER_PINS \
	-Igl/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

gl.i: main_tb.v main.hex gl/wb_interface.simple.v
	iverilog -E -DSIM -DFUNCTIONAL -DSPOOF_FAST_FLASH=\"main.hex\" \
	-Igl/ \
        -I $(CARAVEL)/verilog/rtl \
        -I $(CARAVEL)/verilog/dv/caravel \
	-I $(PDK_ROOT)/sky130A \
	$< -o $@

gl.out: gl.vvp
	vvp $< | tee $@

# To speed-up simulation, remove tap/diode/decap/fill cells
YOSYS_SIMPLE=yosys -p "read_verilog $<; \
	 delete t:sky130_fd_sc_hd__diode_2; \
	 delete t:sky130_fd_sc_hd__decap*; \
	 delete t:sky130_fd_sc_hd__fill*; \
	 delete t:sky130_fd_sc_hd__tapvpwrvgnd_1; \
	 delete t:sky130_fd_sc_hs__diode_2; \
	 delete t:sky130_fd_sc_hs__decap*; \
	 delete t:sky130_fd_sc_hs__fill*; \
	 delete t:sky130_fd_sc_hs__tapvpwrvgnd_1; \
	 delete t:sky130_fd_sc_ms__decap*; \
	 delete t:sky130_fd_sc_ms__fill*; \
	 delete t:sky130_fd_sc_ms__tapvpwrvgnd_1; \
	 write_verilog -noattr $@"

gl/wb_interface.simple.v: ../verilog/gl/wb_interface.v
	$(YOSYS_SIMPLE)

gl/wb_extender.simple.v: ../verilog/gl/wb_extender.v
	$(YOSYS_SIMPLE)

gl/rescue_top.simple.v: ../verilog/gl/rescue_top.v
	$(YOSYS_SIMPLE)

gl/fd_hd.simple.v: ../verilog/gl/fd_hd.v
	$(YOSYS_SIMPLE)

gl/delayline_9_hd.simple.v: ../verilog/gl/delayline_9_hd.v
	$(YOSYS_SIMPLE)

gl/fd_hd_25_1.simple.v: ../verilog/gl/fd_hd_25_1.v
	$(YOSYS_SIMPLE)

gl/delayline_9_hd_25_1.simple.v: ../verilog/gl/delayline_9_hd_25_1.v
	$(YOSYS_SIMPLE)

gl/tdc_inline_1.simple.v: ../verilog/gl/tdc_inline_1.v
	$(YOSYS_SIMPLE)

gl/tdc_inline_2.simple.v: ../verilog/gl/tdc_inline_2.v
	$(YOSYS_SIMPLE)

gl/tdc_inline_3.simple.v: ../verilog/gl/tdc_inline_3.v
	$(YOSYS_SIMPLE)

gl/fd_hs.simple.v: ../verilog/gl/fd_hs.v
	$(YOSYS_SIMPLE)

gl/delayline_9_hs.simple.v: ../verilog/gl/delayline_9_hs.v
	$(YOSYS_SIMPLE)

gl/fd_ms.simple.v: ../verilog/gl/fd_ms.v
	$(YOSYS_SIMPLE)

gl/delayline_9_ms.simple.v: ../verilog/gl/delayline_9_ms.v
	$(YOSYS_SIMPLE)

gl/fd_inline_1.simple.v: ../verilog/gl/fd_inline_1.v
	$(YOSYS_SIMPLE)

gl/tdc_hd_cbuf2_x4.simple.v: ../verilog/gl/tdc_hd_cbuf2_x4.v
	$(YOSYS_SIMPLE)

gl/tapline_200_x4_cbuf2_hd.simple.v: ../verilog/gl/tapline_200_x4_cbuf2_hd.v
	$(YOSYS_SIMPLE)

%.elf: %.c $(FIRMWARE_PATH)/sections.lds $(FIRMWARE_PATH)/start.s
	$(CC) -mabi=ilp32 -march=rv32imc -I$(FIRMWARE_PATH) -O -Wl,-Bstatic,-T,$(FIRMWARE_PATH)/sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ $(FIRMWARE_PATH)/start.s $<

%.hex: %.elf
	$(CROSS)objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -i 's/@10000000/@00000000/g' $@

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd *.log

.PHONY: clean hex all
